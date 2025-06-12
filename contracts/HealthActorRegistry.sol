// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// You need to deploy/import this separately
interface HealthIDNFT {
    function mintCredential(address to, uint256 tokenId, string memory uri) external;
}

contract HealthActorRegistry is AccessControl {
    using Address for address payable;

    bytes32 public constant REGISTRAR_ROLE = keccak256("REGISTRAR_ROLE");

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

    IERC20 public rewardsToken;
    HealthIDNFT public credentialNFT;

    uint256 public constant ACTOR_REWARD = 10 * 10**18;
    uint256 public constant DONATION_REWARD_RATE = 100; // 100 FLB per ETH

    event ActorVerified(address indexed actor, Role role, string name);
    event ActorRemoved(address indexed actor);
    event DonationReceived(address indexed donor, uint256 amount);

    constructor(
        address admin,
        IERC20 _rewardsToken,
        HealthIDNFT _credentialNFT
    ) {
        require(admin != address(0), "Admin address required");
        require(address(_rewardsToken) != address(0), "Token required");
        require(address(_credentialNFT) != address(0), "NFT required");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(REGISTRAR_ROLE, admin);

        rewardsToken = _rewardsToken;
        credentialNFT = _credentialNFT;
    }

    function donateToHealthActors() external payable {
        require(msg.value > 0, "Donation must be greater than 0");
        totalDonations += msg.value;
        donorBalances[msg.sender] += msg.value;
        emit DonationReceived(msg.sender, msg.value);

        // FLB rewards
        uint256 rewardAmount = msg.value * DONATION_REWARD_RATE;
        rewardsToken.transfer(msg.sender, rewardAmount);
    }

    function verifyHealthActor(
        address actorAddress,
        Role role,
        string calldata name,
        string calldata licenseId,
        string calldata phone
    ) external onlyRole(REGISTRAR_ROLE) {
        require(actorAddress != address(0), "Invalid actor address");

        actors[actorAddress] = Actor({
            verified: true,
            role: role,
            name: name,
            licenseId: licenseId,
            phone: phone
        });

        emit ActorVerified(actorAddress, role, name);

        // Mint soulbound NFT
        credentialNFT.mintCredential(
            actorAddress,
            uint256(uint160(actorAddress)),
            tokenURIForActor(role, name)
        );

        // Send FLB token reward
        rewardsToken.transfer(actorAddress, ACTOR_REWARD);
    }

    function batchVerifyActors(
        address[] calldata addresses,
        Role[] calldata roles,
        string[] calldata names,
        string[] calldata licenseIds,
        string[] calldata phones
    ) external onlyRole(REGISTRAR_ROLE) {
        require(
            addresses.length == roles.length &&
            addresses.length == names.length &&
            addresses.length == licenseIds.length &&
            addresses.length == phones.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < addresses.length; i++) {
            actors[addresses[i]] = Actor({
                verified: true,
                role: roles[i],
                name: names[i],
                licenseId: licenseIds[i],
                phone: phones[i]
            });

            emit ActorVerified(addresses[i], roles[i], names[i]);

            credentialNFT.mintCredential(
                addresses[i],
                uint256(uint160(addresses[i])),
                tokenURIForActor(roles[i], names[i])
            );

            rewardsToken.transfer(addresses[i], ACTOR_REWARD);
        }
    }

    function withdrawDonations(address payable recipient) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");
        recipient.sendValue(balance);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function tokenURIForActor(Role role, string memory name) internal pure returns (string memory) {
        // Example metadata logic (update to return real IPFS/URI)
        return string(abi.encodePacked("https://example.com/metadata/", name));
    }
}
