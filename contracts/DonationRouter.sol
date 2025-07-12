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
}