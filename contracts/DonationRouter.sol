<<<<<<< HEAD
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IFlamebornToken {
    function mint(address to, uint256 amount) external;
}

interface IHealthActorRegistry {
    function isActorVerified(address actor) external view returns (bool);
}

abstract contract DonationRouter is Ownable, ReentrancyGuard {
    IFlamebornToken public token;
    IHealthActorRegistry public registry;

    event DonationProcessed(
        address indexed donor,
        address indexed recipient,
        uint256 amountDonated,
        uint256 tokensMinted
    );

    constructor(address _token, address _registry) {
        require(_token != address(0), "Invalid token address");
        require(_registry != address(0), "Invalid registry address");
        token = IFlamebornToken(_token);
        registry = IHealthActorRegistry(_registry);
    }

    function donate(address recipient) external payable nonReentrant {
        require(msg.value > 0, "Donation amount must be > 0");
        require(registry.isActorVerified(recipient), "Recipient not verified");

        // Mint FLB tokens to donor (1:1 with wei)
        token.mint(msg.sender, msg.value);

        // Send funds to recipient
        (bool success, ) = payable(recipient).call{value: msg.value}("");
        require(success, "Transfer failed");

        emit DonationProcessed(msg.sender, recipient, msg.value, msg.value);
    }

    function updateContracts(address newToken, address newRegistry) external onlyOwner {
        require(newToken != address(0) && newRegistry != address(0), "Invalid addresses");
        token = IFlamebornToken(newToken);
        registry = IHealthActorRegistry(newRegistry);
    }
=======
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IFlameBornToken {
    function mintAfterValidation(address to, uint256 amount, string calldata interventionProof) external;
    function rewardYouthAction(address youth, uint256 amount, string calldata actionType) external;
}

interface IHealthActorRegistry {
    function actors(address actor) external view returns (bool verified, string memory segment, uint256 successCount, uint256 upgradeLevel);
    function recordIntervention(address facility, string calldata proof, uint256 successIncrement) external;
}

contract DonationRouter is AccessControl, ReentrancyGuard {
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 public constant CONFIGURER_ROLE = keccak256("CONFIGURER_ROLE");

    IFlameBornToken public flbToken;
    IHealthActorRegistry public registry;

    uint256 public totalUnvalidatedEscrowedAmount;

    struct Escrow {
        address donor;
        address facility;
        uint256 amount;
        bool validated;
        uint48 timestamp;
    }

    Escrow[] public escrows;
    address public treasury;

    uint256 public validationTimeout = 90 days;

    event DonationEscrowed(uint256 indexed escrowId, address indexed donor, address indexed facility, uint256 amount);
    event InterventionValidated(uint256 indexed escrowId, address indexed facility, string proof, uint256 allocatedToFacility, uint256 allocatedToTreasury, uint256 remainingDust);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event ValidationTimeoutUpdated(uint256 indexed oldTimeout, uint256 indexed newTimeout);
    event DonationReclaimed(uint256 indexed escrowId, address indexed donor, uint256 amount);

    constructor(address _token, address _registry, address _treasury) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VALIDATOR_ROLE, msg.sender);
        _grantRole(CONFIGURER_ROLE, msg.sender);

        require(_token != address(0), "DR: Invalid token address");
        require(_registry != address(0), "DR: Invalid registry address");
        require(_treasury != address(0), "DR: Invalid treasury address");

        flbToken = IFlameBornToken(_token);
        registry = IHealthActorRegistry(_registry);
        treasury = _treasury;
    }

    function donate(address facility) external payable nonReentrant {
        (bool verified, , , ) = registry.actors(facility);
        require(verified, "DR: Facility is not verified by HealthActorRegistry");
        require(msg.value > 0, "DR: Donation amount must be greater than zero");
        require(facility != address(0), "DR: Facility address cannot be zero");

        uint256 escrowId = escrows.length;
        escrows.push(Escrow({
            donor: msg.sender,
            facility: facility,
            amount: msg.value,
            validated: false,
            timestamp: uint48(block.timestamp)
        }));

        totalUnvalidatedEscrowedAmount += msg.value;

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
        // Changed to 'calldata' for optimization
        string calldata proof, 
        uint256 successUnits
    ) external onlyRole(VALIDATOR_ROLE) nonReentrant {
        require(escrowId < escrows.length, "DR: Invalid escrow ID");
        Escrow storage escrow = escrows[escrowId];
        require(!escrow.validated, "DR: Escrow already validated");
        require(bytes(proof).length > 0, "DR: Proof cannot be empty");

        escrow.validated = true;
        totalUnvalidatedEscrowedAmount -= escrow.amount;

        // 1. Record intervention in the HealthActorRegistry
        registry.recordIntervention(escrow.facility, proof, successUnits);

        // 2. Allocate funds based on V2 percentages
        // Optimized variable usage to reduce stack depth
        uint256 totalEscrowAmount = escrow.amount;
        uint256 toFacility; // Declare without assignment
        uint256 totalToTreasury; // Declare without assignment
        uint256 remainingDust; // Declare without assignment

        // Perform calculations
        toFacility = (totalEscrowAmount * 70) / 100;
        totalToTreasury = (totalEscrowAmount * 30) / 100; // Directly sum up 10+10+5+5 = 30% for treasury

        // If you need the individual guardian/platform/emergency/scrolls values later,
        // you would calculate them, but for the transfer to treasury, this single sum is sufficient.
        // uint256 toGuardians = (totalEscrowAmount * 10) / 100;
        // uint256 toPlatform = (totalEscrowAmount * 10) / 100;
        // uint256 toEmergency = (totalEscrowAmount * 5) / 100;
        // uint256 toScrolls = (totalEscrowAmount * 5) / 100;
        // totalToTreasury = toGuardians + toPlatform + toEmergency + toScrolls;

        remainingDust = totalEscrowAmount - toFacility - totalToTreasury;

        // 3. Fund transfers using .call for robustness
        (bool facilitySuccess, ) = payable(escrow.facility).call{value: toFacility}("");
        require(facilitySuccess, "DR: Facility ETH transfer failed");

        (bool treasurySuccess, ) = payable(treasury).call{value: totalToTreasury}("");
        require(treasurySuccess, "DR: Treasury ETH transfer failed");
        
        if (remainingDust > 0) {
            (bool dustSuccess, ) = payable(treasury).call{value: remainingDust}("");
            require(dustSuccess, "DR: Remaining dust transfer to treasury failed");
        }

        // 4. Mint FLB tokens to donor (post-validation)
        flbToken.mintAfterValidation(escrow.donor, totalEscrowAmount, proof);

        emit InterventionValidated(escrowId, escrow.facility, proof, toFacility, totalToTreasury, remainingDust);
    }

    function reclaimDonation(uint256 escrowId) external nonReentrant {
        require(escrowId < escrows.length, "DR: Invalid escrow ID");
        Escrow storage escrow = escrows[escrowId];
        require(msg.sender == escrow.donor, "DR: Only donor can reclaim");
        require(!escrow.validated, "DR: Escrow already validated, cannot reclaim");
        require(block.timestamp >= escrow.timestamp + validationTimeout, "DR: Validation timeout not reached");

        escrow.validated = true;
        totalUnvalidatedEscrowedAmount -= escrow.amount;

        (bool success, ) = payable(escrow.donor).call{value: escrow.amount}("");
        require(success, "DR: Failed to reclaim donation");

        emit DonationReclaimed(escrowId, escrow.donor, escrow.amount);
    }

    function rewardYouth(
        address youth,
        uint256 amount,
        string memory actionType
    ) external onlyRole(VALIDATOR_ROLE) {
        require(youth != address(0), "DR: Youth address cannot be zero");
        require(amount > 0, "DR: Reward amount must be greater than zero");
        require(bytes(actionType).length > 0, "DR: Action type cannot be empty");

        flbToken.rewardYouthAction(youth, amount, actionType);
    }

    function updateTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newTreasury != address(0), "DR: New treasury address cannot be zero");
        emit TreasuryUpdated(treasury, newTreasury);
        treasury = newTreasury;
    }

    function updateValidationTimeout(uint256 _newTimeout) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_newTimeout > 0, "DR: Timeout must be greater than zero");
        emit ValidationTimeoutUpdated(validationTimeout, _newTimeout);
        validationTimeout = _newTimeout;
    }

    function recoverAccidentalEth() external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        uint256 contractBalance = address(this).balance;
        uint256 recoverableBalance = contractBalance - totalUnvalidatedEscrowedAmount;
        
        require(recoverableBalance > 0, "DR: No accidental ETH to recover or all ETH is escrowed.");

        (bool success, ) = payable(msg.sender).call{value: recoverableBalance}("");
        require(success, "DR: Failed to recover accidental ETH");
    }

    receive() external payable {
        revert("DR: Direct Ether transfers not allowed. Use donate function.");
    }
>>>>>>> c9874bb596487dce653a969c1777b6d1101d4a97
}