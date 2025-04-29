// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract HealthActorRegistry is AccessControl {
    bytes32 public constant REGISTRAR_ROLE = keccak256("REGISTRAR_ROLE");
    
    // Track donations and balances
    uint256 public totalDonations;
    mapping(address => uint256) public donorBalances;

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
    event DonationReceived(address indexed donor, uint256 amount);

    constructor(address admin) {
        require(admin != address(0), "Admin address required");
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(REGISTRAR_ROLE, admin);
    }

    // Simplified donation function
    function donateToHealthActors() external payable {
        require(msg.value > 0, "Donation must be greater than 0");
        totalDonations += msg.value;
        donorBalances[msg.sender] += msg.value;
        emit DonationReceived(msg.sender, msg.value);
    }

    // Proper actor verification with donation tracking
    function verifyHealthActor(
        address actorAddress,
        Role role,
        string calldata name,
        string calldata licenseId,
        string calldata phone
    ) external onlyRole(REGISTRAR_ROLE) {
        actors[actorAddress] = Actor({
            verified: true,
            role: role,
            name: name,
            licenseId: licenseId,
            phone: phone
        });
        
        emit ActorVerified(actorAddress, role, name);
    }

    // Batch verification function
    function batchVerifyActors(
        address[] calldata addresses,
        Role[] calldata roles,
        string[] calldata names,
        string[] calldata licenseIds,
        string[] calldata phones
    ) external onlyRole(REGISTRAR_ROLE) {
        require(addresses.length == roles.length, "Array length mismatch");
        require(addresses.length == names.length, "Array length mismatch");
        
        for (uint256 i = 0; i < addresses.length; i++) {
            actors[addresses[i]] = Actor({
                verified: true,
                role: roles[i],
                name: names[i],
                licenseId: licenseIds[i],
                phone: phones[i]
            });
            emit ActorVerified(addresses[i], roles[i], names[i]);
        }
    }

    // Safe withdrawal function
    function withdrawDonations(address payable recipient) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");
        Address.sendValue(recipient, balance);
    }

    // Get contract balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}