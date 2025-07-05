// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// ======================
// FlameBornToken.sol
// ======================
contract FlameBornToken is ERC20, AccessControl {
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");
    bytes32 public constant YOUTH_ROLE = keccak256("YOUTH_ROLE");
    
    // Soulbound properties
    mapping(address => bool) private _soulbound;
    mapping(address => string) private _africanID;
    
    constructor() ERC20("Flameborn Token", "FLB") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VALIDATOR_ROLE, msg.sender);
        _grantRole(DAO_ROLE, msg.sender);
        
        // Genesis drop to African validators
        _mint(msg.sender, 100 * 10 ** decimals());
        _soulbound[msg.sender] = true;
    }

    // African identity registration
    function registerAfricanID(string memory idHash) external {
        require(bytes(_africanID[msg.sender]).length == 0, "Already registered");
        _africanID[msg.sender] = idHash;
    }

    // Minting by VALIDATOR_ROLE only after verification
    function mintAfterValidation(
        address to,
        uint256 amount,
        string memory interventionProof
    ) external onlyRole(VALIDATOR_ROLE) {
        require(_isAfrican(to), "Only African recipients");
        _mint(to, amount);
        _soulbound[to] = true;
        // Additional logic for HFE Grid upgrades
    }

    // Override transfers to enforce soulbound
    function _transfer(address, address, uint256) internal pure override {
        revert("FLB is soulbound and non-transferable");
    }

    // African identity verification
    function _isAfrican(address account) internal view returns (bool) {
        return bytes(_africanID[account]).length > 0;
    }

    // Youth rewards for Flameborn Youth Grid
    function rewardYouthAction(
        address youth,
        uint256 amount,
        string memory actionType
    ) external onlyRole(YOUTH_ROLE) {
        require(_isAfrican(youth), "Only African youth");
        _mint(youth, amount);
    }
}

