// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title HealthActorRegistry
 * @notice Manages verification of doctors, clinics, nurses, etc. in the FlameBorn system.
 */
contract HealthActorRegistry is AccessControl {
    bytes32 public constant REGISTRAR_ROLE = keccak256("REGISTRAR_ROLE");

    enum Role {
        Unset,
        Doctor,
        Nurse,
        Clinic,
        OutreachTeam,
        CommunityHealthWorker
    }

    struct Actor {
        bool verified;
        Role role;
        string name;
        string licenseId;
        string phone;
    }

    mapping(address => Actor) public actors;

    event ActorVerified(address indexed actor, Role role, string name);
    event ActorRemoved(address indexed actor);

    /**
     * @notice Constructor to set up admin and registrar roles.
     * @param admin The Gnosis Safe or deployer that will manage registry rights.
     */
    constructor(address admin) {
        require(admin != address(0), "Admin address is required");
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(REGISTRAR_ROLE, admin);
    }

    // ... (Rest of your contract stays unchanged)
}
