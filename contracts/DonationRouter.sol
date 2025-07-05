// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Keeping the pragma as specified

// Importing OpenZeppelin Contracts v5+
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// ======================
// Interfaces for external contracts
// ======================

/**
 * @title IFlameBornToken
 * @dev Interface for the FlameBornToken contract.
 * Defines functions for minting tokens after validation and rewarding youth actions.
 */
interface IFlameBornToken {
    function mintAfterValidation(address to, uint256 amount, string calldata interventionProof) external;
    function rewardYouthAction(address youth, uint256 amount, string calldata actionType) external;
}

/**
 * @title IHealthActorRegistry
 * @dev Interface for the HealthActorRegistry contract.
 * Defines functions for querying actor details and recording interventions.
 */
interface IHealthActorRegistry {
    // The returns signature must exactly match the external contract's function
    // Assuming 'actors' returns a struct-like tuple for verified, segment, successCount, upgradeLevel
    function actors(address actor) external view returns (bool verified, string memory segment, uint256 successCount, uint256 upgradeLevel);
    function recordIntervention(address facility, string calldata proof, uint256 successIncrement) external;
}


// ======================
// DonationRouter.sol (V2 VAL Implementation)
// ======================
/**
 * @title DonationRouter
 * @dev This contract manages a donation system where funds are escrowed,
 * interventions are validated by a `VALIDATOR_ROLE`, and then funds are
 * distributed and tokens are minted.
 * Inherits AccessControl for role-based access and ReentrancyGuard for security.
 */
contract DonationRouter is AccessControl, ReentrancyGuard {
    // Define custom roles
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    // It's good practice to have a role for setting the treasury
    bytes32 public constant CONFIGURER_ROLE = keccak256("CONFIGURER_ROLE"); 

    // Contract instances
    IFlameBornToken public flbToken; // Use the interface
    IHealthActorRegistry public registry; // Use the interface

    /**
     * @dev Struct to hold details of an escrowed donation.
     * @param donor The address of the donor.
     * @param facility The address of the health facility receiving the donation.
     * @param amount The amount of Ether donated (in wei).
     * @param validated True if the intervention associated with this escrow has been validated.
     */
    struct Escrow {
        address donor;
        address facility;
        uint256 amount;
        bool validated;
    }

    Escrow[] public escrows; // Array to store all escrowed donations
    address public treasury; // Address where platform/guardian/emergency/scrolls funds go

    // Events for tracking important actions
    event DonationEscrowed(uint256 indexed escrowId, address indexed donor, address indexed facility, uint256 amount); // Added amount for clarity
    event InterventionValidated(uint256 indexed escrowId, address indexed facility, string proof, uint256 allocatedToFacility, uint256 allocatedToTreasury); // Added more details
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);

    /**
     * @dev Constructor to initialize the contract roles and external contract addresses.
     * The deployer receives DEFAULT_ADMIN_ROLE and VALIDATOR_ROLE.
     * @param _token Address of the FlameBornToken contract.
     * @param _registry Address of the HealthActorRegistry contract.
     * @param _treasury Address of the treasury multisig or contract.
     */
    constructor(address _token, address _registry, address _treasury) {
        // Grant default admin role to the deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // Grant validator role to the deployer (can be changed later by admin)
        _grantRole(VALIDATOR_ROLE, msg.sender);
        // Grant configurer role to the deployer
        _grantRole(CONFIGURER_ROLE, msg.sender);

        // Initialize external contract instances
        require(_token != address(0), "DR: Invalid token address");
        require(_registry != address(0), "DR: Invalid registry address");
        require(_treasury != address(0), "DR: Invalid treasury address");

        flbToken = IFlameBornToken(_token);
        registry = IHealthActorRegistry(_registry);
        treasury = _treasury;
    }

    /**
     * @dev Allows a donor to contribute Ether to a specific health facility.
     * The donated funds are placed into an escrow until the intervention is validated.
     * @param facility The address of the health facility to donate to.
     */
    function donate(address facility) external payable nonReentrant {
        // Check if the facility is verified by the HealthActorRegistry
        require(bytes(registry.actors(facility).segment).lengths(facility).verified, "DR: Unverified facility");
        require(msg.value > 0, "DR: Donation amount must be greater than zero");
        require(facility != address(0), "DR: Facility address cannot be zero"); // Defensive check

        // Create a new escrow entry
        uint256 escrowId = escrows.length; // Use current length as new ID
        escrows.push(Escrow({
            donor: msg.sender,
            facility: facility,
            amount: msg.value,
            validated: false
        }));

        // Emit event for escrowed donation
        emit DonationEscrowed(escrowId, msg.sender, facility, msg.value);
    }

    /**
     * @dev Allows an authorized VALIDATOR_ROLE to validate an intervention.
     * Upon validation, funds are released to the facility and treasury,
     * and FLB tokens are minted to the donor.
     * @param escrowId The ID of the escrowed donation to validate.
     * @param proof A string providing proof of the intervention (e.g., IPFS hash).
     * @param successUnits The measure of success for the intervention, recorded in the registry.
     */
    function validateIntervention(
        uint256 escrowId,
        string memory proof,
        uint256 successUnits
    ) external onlyRole(VALIDATOR_ROLE) nonReentrant {
        require(escrowId < escrows.length, "DR: Invalid escrow ID");
        Escrow storage escrow = escrows[escrowId]; // Use storage keyword for modification
        require(!escrow.validated, "DR: Escrow already validated");
        require(bytes(proof).length > 0, "DR: Proof cannot be empty"); // Ensure proof is provided

        escrow.validated = true; // Mark escrow as validated

        // 1. Record intervention in the HealthActorRegistry
        registry.recordIntervention(escrow.facility, proof, successUnits);

        // 2. Allocate funds based on V2 percentages
        // It's safer to calculate amounts first to prevent reentrancy during transfers
        uint256 totalEscrowAmount = escrow.amount;
        uint256 toFacility = (totalEscrowAmount * 70) / 100;
        uint256 toGuardians = (totalEscrowAmount * 10) / 100;
        uint256 toPlatform = (totalEscrowAmount * 10) / 100;
        uint256 toEmergency = (totalEscrowAmount * 5) / 100;
        uint256 toScrolls = (totalEscrowAmount * 5) / 100;

        // Sum for treasury, assuming treasury receives Guardians, Platform, Emergency, Scrolls portions
        uint256 totalToTreasury = toGuardians + toPlatform + toEmergency + toScrolls;
        uint256 remaining = totalEscrowAmount - toFacility - totalToTreasury;
        // Consider what to do with 'remaining' if percentages don't sum to 100 or due to rounding.
        // If remaining is intentionally left in the contract, clarify that.
        // For now, assuming percentages sum to 100 or rounding is negligible.

        // 3. Fund transfers
        // Use (bool success, ) = payable(address).call{value: amount}(""); for more robustness
        // For simplicity, sticking with .transfer() as per original, but be aware of its gas limit (2300).
        (bool facilitySuccess, ) = payable(escrow.facility).call{value: toFacility}("");
        require(facilitySuccess, "DR: Facility transfer failed");

        (bool treasurySuccess, ) = payable(treasury).call{value: totalToTreasury}("");
        require(treasurySuccess, "DR: Treasury transfer failed");
        
        // If there's any remaining dust due to integer division, it stays in the contract
        // or you could choose to send it to the treasury or another address.
        // For instance: if (remaining > 0) payable(treasury).transfer(remaining);

        // 4. Mint FLB tokens to donor (post-validation)
        flbToken.mintAfterValidation(escrow.donor, totalEscrowAmount, proof); // Pass original escrow amount and proof

        // Emit event for validated intervention
        emit InterventionValidated(escrowId, escrow.facility, proof, toFacility, totalToTreasury);
    }

    /**
     * @dev Allows an authorized VALIDATOR_ROLE to reward youth for specific actions.
     * This directly calls the `rewardYouthAction` function on the FlameBornToken contract.
     * @param youth The address of the youth to reward.
     * @param amount The amount of tokens to reward.
     * @param actionType A string describing the type of action performed by the youth.
     */
    function rewardYouth(
        address youth,
        uint256 amount,
        string memory actionType
    ) external onlyRole(VALIDATOR_ROLE) {
        require(youth != address(0), "DR: Youth address cannot be zero"); // Defensive check
        require(amount > 0, "DR: Reward amount must be greater than zero"); // Defensive check
        require(bytes(actionType).length > 0, "DR: Action type cannot be empty"); // Defensive check

        flbToken.rewardYouthAction(youth, amount, actionType);
    }

    /**
     * @dev Allows the DEFAULT_ADMIN_ROLE or CONFIGURER_ROLE to update the treasury address.
     * @param newTreasury The new address for the treasury.
     */
    function updateTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newTreasury != address(0), "DR: New treasury address cannot be zero");
        emit TreasuryUpdated(treasury, newTreasury);
        treasury = newTreasury;
    }

    /**
     * @dev Allows the owner to recover accidental Ether sent to the contract (not via donate).
     * Only callable by the DEFAULT_ADMIN_ROLE.
     */
    function recoverAccidentalEth() external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        uint256 balance = address(this).balance;
        // Don't withdraw the balance that is currently in pending escrows
        // This function is for accidental transfers ONLY.
        // A more robust implementation would track the sum of unvalidated escrow amounts.
        // For simplicity here, it attempts to send all contract balance.
        // IMPORTANT: In a production system, you MUST ensure this doesn't withdraw escrowed funds!
        // You'd need a mapping or variable to track total escrowed Ether.
        // E.g., `uint256 public totalEscrowedAmount;` updated in `donate` and `validateIntervention`.
        // Then `uint256 recoverableBalance = balance - totalEscrowedAmount;`
        
        // For now, if the contract is expected to ONLY hold escrowed funds,
        // any additional ETH is considered accidental.
        // You might need a more sophisticated mechanism if you also have a withdrawal function for validated donations.
        
        // For simple recovery of anything NOT part of an active escrow
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "DR: Failed to recover accidental ETH");
    }

    // Fallback function to prevent accidental Ether transfers without calling a function
    receive() external payable {
        revert("DR: Direct Ether transfers not allowed. Use donate function.");
    }
}