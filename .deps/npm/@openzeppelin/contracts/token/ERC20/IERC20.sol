// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title FlameBornToken
/// @notice Soulbound identity token for verified African youth & social validators
contract FlameBornToken is ERC20, AccessControl {
    // --- Custom Errors (Gas-Saving) ---
    error ZeroAddress();
    error AlreadyRegistered();
    error NotRegistered();
    error EmptyString();
    error TransferDisabled();
    error MintingClosed();
    error InvalidAmount();

    // --- Role Identifiers ---
    bytes32 private constant DAO_ROLE = keccak256("DAO_ROLE");
    bytes32 private constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 private constant YOUTH_ROLE = keccak256("YOUTH_ROLE");

    // --- Soulbinding / Identity ---
    mapping(address => string) private _africanID;
    mapping(address => bool) private _soulbound;

    // --- Initialization Flag ---
    bool public initialMintComplete;

    // --- Events ---
    event AfricanIDRegistered(address indexed user, string idHash);
    event ValidatorMint(address indexed to, uint256 amount, string proof);
    event YouthReward(address indexed to, uint256 amount, string action);
    event ControlledMint(address indexed to, uint256 amount);
    event FLBBurned(uint256 amount);
    event SoulprintIssued(address indexed user, string hash, uint256 weight, address indexed issuedBy);

    /// @notice Constructor — mints initial supply to DAO & sets admin roles
    /// @param initialSupply Initial token supply (whole tokens, not wei)
    constructor(uint256 initialSupply) payable ERC20("FlameBorn Token", "FLB") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DAO_ROLE, msg.sender);
        _grantRole(VALIDATOR_ROLE, msg.sender);
        _grantRole(YOUTH_ROLE, msg.sender);

        uint256 fullAmount = initialSupply * 1e18;
        _mint(msg.sender, fullAmount);
        _soulbound[msg.sender] = true;
        initialMintComplete = true;
    }

    /// @dev Overrides ERC20 to disable transfers
    function _update(address from, address to, uint256 value) internal override {
        if (from != address(0) && to != address(0)) revert TransferDisabled();
        super._update(from, to, value);

        if (from == address(0) && !_soulbound[to]) {
            _soulbound[to] = true;
        }
    }

    /// @notice Register an African ID (once only)
    function registerAfricanID(string calldata idHash) external {
        if (bytes(idHash).length == 0) revert EmptyString();
        if (bytes(_africanID[msg.sender]).length != 0) revert AlreadyRegistered();

        _africanID[msg.sender] = idHash;
        emit AfricanIDRegistered(msg.sender, idHash);
    }

    /// @notice Validator mints tokens to a verified African with audit metadata
    function mintAfterValidation(address to, uint256 amount, string calldata proof)
        external onlyRole(VALIDATOR_ROLE)
    {
        if (to == address(0)) revert ZeroAddress();
        if (!_isAfrican(to)) revert NotRegistered();
        if (amount == 0) revert InvalidAmount();
        if (bytes(proof).length == 0) revert EmptyString();

        _mint(to, amount);
        emit ValidatorMint(to, amount, proof);
    }

    /// @notice Youth reward distribution for verified social participation
    function rewardYouthAction(address youth, uint256 amount, string calldata action)
        external onlyRole(YOUTH_ROLE)
    {
        if (youth == address(0)) revert ZeroAddress();
        if (!_isAfrican(youth)) revert NotRegistered();
        if (amount == 0) revert InvalidAmount();
        if (bytes(action).length == 0) revert EmptyString();

        _mint(youth, amount);
        emit YouthReward(youth, amount, action);
    }

    /// @notice Burn FLB tokens from a user
    function burn(address from, uint256 amount) external onlyRole(DAO_ROLE) {
        if (from == address(0)) revert ZeroAddress();
        _burn(from, amount);
        emit FLBBurned(amount);
    }

    /// @notice Admin-controlled minting for initialization (one-time only)
    function controlledMint(address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (to == address(0)) revert ZeroAddress();
        if (initialMintComplete) revert MintingClosed();

        _mint(to, amount);
        initialMintComplete = true;
        _soulbound[to] = true;
        emit ControlledMint(to, amount);
    }

    /// @notice DAO can issue symbolic soulprint metadata
    function issueSoulprint(address user, string calldata soulHash, uint256 weight)
        external onlyRole(DAO_ROLE)
    {
        if (!_isAfrican(user)) revert NotRegistered();
        if (bytes(soulHash).length == 0) revert EmptyString();

        emit SoulprintIssued(user, soulHash, weight, msg.sender);
    }

    /// @notice Returns registered African ID hash of user
    function getAfricanID(address account) external view returns (string memory) {
        return _africanID[account];
    }

    /// @dev Internal check for African ID registration
    function _isAfrican(address user) internal view returns (bool) {
        return bytes(_africanID[user]).length != 0;
    }

    /// @notice Override decimals to return 18
    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
