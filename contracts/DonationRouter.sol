// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24; // Keeping your specified pragma version

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol"; // Updated import path for Ownable v5+
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol"; // Updated import path for ReentrancyGuard v5+

interface IFlamebornToken {
    function mint(address to, uint256 amount) external;
}

interface IHealthActorRegistry {
    function isActorVerified(address actor) external view returns (bool);
}

// Updated contract to inherit from Ownable and ReentrancyGuard.
// Note: Ownable no longer requires a constructor argument in v5+.
abstract contract DonationRouter is Ownable, ReentrancyGuard {
    IFlamebornToken public token;
    IHealthActorRegistry public registry;

    event DonationProcessed(
        address indexed donor,
        address indexed recipient,
        uint256 amountDonated,
        uint256 tokensMinted
    );

    /**
     * @dev Constructor to initialize the contract with addresses for the token and registry.
     * The deployer of this contract will automatically become the owner due to Ownable v5+.
     * @param _token The address of the IFlamebornToken contract.
     * @param _registry The address of the IHealthActorRegistry contract.
     */
    constructor(address _token, address _registry) {
        // Ownable's constructor is implicitly called, setting msg.sender as owner.
        require(_token != address(0), "DonationRouter: Invalid token address");
        require(_registry != address(0), "DonationRouter: Invalid registry address");
        token = IFlamebornToken(_token);
        registry = IHealthActorRegistry(_registry);
    }

    /**
     * @dev Fallback function to accept Ether directly to the contract.
     * This makes the contract able to receive Ether without a function call.
     */
    receive() external payable {}

    /**
     * @dev Allows a user to donate Ether to a verified recipient and receive FLB tokens.
     * The donated Ether is sent to the recipient, and an equal amount of FLB tokens
     * is minted to the donor.
     * @param recipient The address of the health actor to receive the donation.
     */
    function donate(address recipient) external payable nonReentrant {
        require(msg.value > 0, "DonationRouter: Donation amount must be > 0");
        require(recipient != address(0), "DonationRouter: Recipient address cannot be zero"); // Added check
        require(registry.isActorVerified(recipient), "DonationRouter: Recipient not verified");

        // Mint FLB tokens to donor (1:1 with wei)
        // Ensure the token contract has allowance or is configured to allow minting by this contract.
        token.mint(msg.sender, msg.value);

        // Send funds to recipient
        (bool success, ) = payable(recipient).call{value: msg.value}("");
        require(success, "DonationRouter: Ether transfer failed");

        emit DonationProcessed(msg.sender, recipient, msg.value, msg.value);
    }

    /**
     * @dev Allows the owner to update the addresses of the token and registry contracts.
     * @param newToken The new address for the IFlamebornToken contract.
     * @param newRegistry The new address for the IHealthActorRegistry contract.
     */
    function updateContracts(address newToken, address newRegistry) external onlyOwner {
        require(newToken != address(0), "DonationRouter: New token address cannot be zero"); // Added check
        require(newRegistry != address(0), "DonationRouter: New registry address cannot be zero"); // Added check
        token = IFlamebornToken(newToken);
        registry = IHealthActorRegistry(newRegistry);
    }
}