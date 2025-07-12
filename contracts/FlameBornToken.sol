// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title FlameBornTokenV3
 * @notice Soulbound ERC20 token for identity-based, non-transferable incentives.
 * @dev Fully gas-optimized and protected with proper access control and validation.
 */
contract FlameBornTokenV3 is ERC20, AccessControl {
    // === Custom Errors ===
    error ZeroAddress();
    error AlreadyRegistered();
    error NotRegistered();
    error InvalidProof();
    error ZeroAmount();
    error MintClosed();
    error TransferNotAllowed();

    // === Role Identifiers ===
    bytes32 private constant DAO_ROLE = keccak256("DAO_ROLE");
    bytes32 private constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 private constant YOUTH_ROLE = keccak256("YOUTH_ROLE");

    // === Mappings with named keys (Solidity ≥0.8.18) ===
    mapping(address user => bool) private _soulbound;
    mapping(address user => string) private _africanID;

    // === State flags ===
    bool public initialMintComplete;

    // === Events ===
    event AfricanIDRegistered(address indexed account, string idHash);
    event MintedAfterValidation(address indexed to, uint256 amount, string proof);
    event YouthActionRewarded(address indexed youth, uint256 amount, string action);
    event SymbolicSoulprint(address indexed user, string hash, uint256 weight, address issuedBy);
    event ControlledMint(address indexed to, uint256 amount);
    event FLBBurned(uint256 amount);

    /**
     * @notice Deploys FlameBornTokenV3 and mints initial supply to deployer.
     * @param initialSupply Initial supply (without decimals).
     */
    constructor(uint256 initialSupply) payable ERC20("FlameBorn Token", "FLB") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DAO_ROLE, msg.sender);
        _grantRole(VALIDATOR_ROLE, msg.sender);
        _grantRole(YOUTH_ROLE, msg.sender);

        uint256 minted = initialSupply * 1e18;
        _mint(msg.sender, minted);
        _soulbound[msg.sender] = true;
        initialMintComplete = true;
    }

    /**
     * @dev Disable token transfers permanently (soulbound).
     * Only minting (from == 0) and burning (to == 0) are allowed.
     */
    function _update(address from, address to, uint256 value) internal override {
        if (from != address(0) && to != address(0)) {
            revert TransferNotAllowed();
        }
        super._update(from, to, value);

        if (from == address(0) && !_soulbound[to]) {
            _soulbound[to] = true;
        }
    }

    /**
     * @notice Register a hashed African ID. One-time action.
     * @param idHash Keccak256 hash of user's identity data.
     */
    function registerAfricanID(string calldata idHash) external {
        if (bytes(_africanID[msg.sender]).length != 0) revert AlreadyRegistered();
        if (bytes(idHash).length == 0) revert InvalidProof();

        _africanID[msg.sender] = idHash;
        emit AfricanIDRegistered(msg.sender, idHash);
    }

    /**
     * @notice Mint FLB tokens after verification by validator.
     * @param to Recipient address.
     * @param amount Number of tokens to mint.
     * @param proof Off-chain verification string.
     */
    function mintAfterValidation(
        address to,
        uint256 amount,
        string calldata proof
    ) external onlyRole(VALIDATOR_ROLE) {
        if (to == address(0)) revert ZeroAddress();
        if (!_isAfrican(to)) revert NotRegistered();
        if (amount == 0) revert ZeroAmount();
        if (bytes(proof).length == 0) revert InvalidProof();

        _mint(to, amount);
        emit MintedAfterValidation(to, amount, proof);
    }

    /**
     * @notice Mint tokens to reward youth participation.
     * @param youth Target youth address.
     * @param amount Number of tokens to mint.
     * @param action Short action type string (max 32 bytes).
     */
    function rewardYouthAction(
        address youth,
        uint256 amount,
        string calldata action
    ) external onlyRole(YOUTH_ROLE) {
        if (youth == address(0)) revert ZeroAddress();
        if (!_isAfrican(youth)) revert NotRegistered();
        if (amount == 0) revert ZeroAmount();
        if (bytes(action).length == 0) revert InvalidProof();

        _mint(youth, amount);
        emit YouthActionRewarded(youth, amount, action);
    }

    /**
     * @notice Burn tokens from an account.
     * @param from Source address.
     * @param amount Number of tokens to burn.
     */
    function burn(address from, uint256 amount) external onlyRole(DAO_ROLE) {
        if (from == address(0)) revert ZeroAddress();
        _burn(from, amount);
        emit FLBBurned(amount);
    }

    /**
     * @notice One-time minting for ecosystem bootstrapping.
     * @param to Address to receive the tokens.
     * @param amount Amount to mint.
     */
    function controlledMint(address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (to == address(0)) revert ZeroAddress();
        if (initialMintComplete) revert MintClosed();

        _mint(to, amount);
        initialMintComplete = true;

        if (!_soulbound[to]) {
            _soulbound[to] = true;
        }

        emit ControlledMint(to, amount);
    }

    /**
     * @notice Symbolic metadata-only minting, e.g. social proofs.
     * @param user Recipient address.
     * @param soulHash Hashed symbolic proof string.
     * @param weight Optional numeric weight for indexing.
     */
    function issueSoulprint(address user, string calldata soulHash, uint256 weight)
        external onlyRole(DAO_ROLE)
    {
        if (!_isAfrican(user)) revert NotRegistered();
        if (bytes(soulHash).length == 0) revert InvalidProof();
        emit SymbolicSoulprint(user, soulHash, weight, msg.sender);
    }

    /**
     * @notice View African ID hash of an account.
     * @param account Address to query.
     * @return idHash Registered African ID hash.
     */
    function getAfricanID(address account) external view returns (string memory idHash) {
        idHash = _africanID[account];
    }

    /**
     * @notice Return number of decimals (18).
     * @return Number of decimals (hardcoded to 18).
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /**
     * @dev Check if an address has registered an African ID.
     */
    function _isAfrican(address user) internal view returns (bool) {
        return bytes(_africanID[user]).length != 0;
    }
}
