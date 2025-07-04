// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// ======================
// DonationRouter.sol (V2 VAL Implementation)
// ======================
contract DonationRouter is AccessControl, ReentrancyGuard {
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    
    FlameBornToken public flbToken;
    HealthActorRegistry public registry;
    
    struct Escrow {
        address donor;
        address facility;
        uint256 amount;
        bool validated;
    }
    
    Escrow[] public escrows;
    address public treasury;
    
    event DonationEscrowed(uint256 indexed escrowId, address indexed donor, address indexed facility);
    event InterventionValidated(uint256 indexed escrowId, string proof);

    constructor(address _token, address _registry, address _treasury) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VALIDATOR_ROLE, msg.sender);
        
        flbToken = FlameBornToken(_token);
        registry = HealthActorRegistry(_registry);
        treasury = _treasury;
    }

    // Donate to facility (funds escrowed)
    function donate(address facility) external payable nonReentrant {
        require(registry.actors(facility).verified, "Unverified facility");
        require(msg.value > 0, "Donation required");
        
        uint256 escrowId = escrows.length;
        escrows.push(Escrow({
            donor: msg.sender,
            facility: facility,
            amount: msg.value,
            validated: false
        }));
        
        emit DonationEscrowed(escrowId, msg.sender, facility);
    }

    // VAL: Validate intervention and release funds
    function validateIntervention(
        uint256 escrowId,
        string memory proof,
        uint256 successUnits
    ) external onlyRole(VALIDATOR_ROLE) nonReentrant {
        require(escrowId < escrows.length, "Invalid escrow");
        Escrow storage escrow = escrows[escrowId];
        require(!escrow.validated, "Already validated");
        
        escrow.validated = true;
        
        // 1. Record intervention in registry
        registry.recordIntervention(escrow.facility, proof, successUnits);
        
        // 2. Allocate funds (V2 percentages)
        uint256 toFacility = (escrow.amount * 70) / 100;
        uint256 toGuardians = (escrow.amount * 10) / 100;
        uint256 toPlatform = (escrow.amount * 10) / 100;
        uint256 toEmergency = (escrow.amount * 5) / 100;
        uint256 toScrolls = (escrow.amount * 5) / 100;
        
        // 3. Fund transfers
        payable(escrow.facility).transfer(toFacility);
        payable(treasury).transfer(toGuardians + toPlatform + toEmergency + toScrolls);
        
        // 4. Mint FLB to donor (post-validation)
        flbToken.mintAfterValidation(escrow.donor, escrow.amount, proof);
        
        emit InterventionValidated(escrowId, proof);
    }

    // Youth reward distribution
    function rewardYouth(
        address youth,
        uint256 amount,
        string memory actionType
    ) external onlyRole(VALIDATOR_ROLE) {
        flbToken.rewardYouthAction(youth, amount, actionType);
    }
}

// Interfaces for type safety
interface FlameBornToken {
    function mintAfterValidation(address to, uint256 amount, string memory interventionProof) external;
    function rewardYouthAction(address youth, uint256 amount, string memory actionType) external;
}

interface HealthActorRegistry {
    function actors(address actor) external view returns (bool verified, string memory segment, uint256 successCount, uint256 upgradeLevel);
    function recordIntervention(address facility, string memory proof, uint256 successIncrement) external;
}