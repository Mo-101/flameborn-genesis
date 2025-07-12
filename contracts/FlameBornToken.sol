// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

<<<<<<< HEAD
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Thrown if the multisig wallet address is not valid (zero address).
error InvalidMultisigAddress();

/// @notice Thrown if minting is attempted after the initial mint is complete.
error MintingDisabled();

/// @title FlamebornToken (FLB)
/// @notice Core currency of the FlameBorn ecosystem. Controlled via multisig.
/// @dev Extends OpenZeppelin ERC20 + AccessControl
contract FlamebornToken is ERC20, AccessControl {
    /// @notice Role allowing controlled minting/burning
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");

    /// @notice Initial token supply: 100 FLB
    uint256 public constant INITIAL_SUPPLY = 100 * 10 ** 18;

    /// @notice Flag that disables further minting after initial mint
    bool private _initialMintComplete;

    /// @notice Returns whether the initial mint has been completed
    function initialMintComplete() external view returns (bool) {
        return _initialMintComplete;
    }

    /// @notice Deploys the token and performs initial mint to multisig wallet
    /// @param multisigWallet The address that will receive the initial supply and hold admin rights
    constructor(address multisigWallet) ERC20("Flameborn", "FLB") {
        if (multisigWallet == address(0)) revert InvalidMultisigAddress();

        _grantRole(DEFAULT_ADMIN_ROLE, multisigWallet);
        _grantRole(MULTISIG_ROLE, multisigWallet);

        _mint(multisigWallet, INITIAL_SUPPLY);
        _initialMintComplete = true;
    }

    /// @notice Allows the multisig to burn tokens from a given address
    /// @param from The address whose tokens will be burned
    /// @param amount The amount of tokens to burn
    function burn(address from, uint256 amount) external onlyRole(MULTISIG_ROLE) {
        _burn(from, amount);
    }

    /// @notice (One-time) mint function if future minting is required before lock
    /// @param to The address to receive minted tokens
    /// @param amount The amount of tokens to mint
    function controlledMint(address to, uint256 amount) external onlyRole(MULTISIG_ROLE) {
        if (_initialMintComplete) revert MintingDisabled();

        _mint(to, amount);
        _initialMintComplete = true; // Permanently lock future minting
=======
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title FlameBornToken (Soulbound ERC20)
 * @dev Non-transferable (soulbound) ERC20 with roles for validators, DAO, and youth incentive.
 * - Transfers disabled permanently (soulbound).
 * - African ID registration tied to mint eligibility.
 * - Integrated with analytics events and social impact tracking.
 */
contract FlameBornToken is ERC20, AccessControl {
    // === Roles ===
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");
    bytes32 public constant YOUTH_ROLE = keccak256("YOUTH_ROLE");

    // === Identity & Soulbinding ===
    mapping(address => bool) private _soulbound;
    mapping(address => string) private _africanID;

    // === State flags ===
    bool public initialMintComplete = false;

    // === Events ===
    event AfricanIDRegistered(address indexed account, string idHash);
    event MintedAfterValidation(address indexed to, uint256 amount, string interventionProof);
    event YouthActionRewarded(address indexed youth, uint256 amount, string actionType);
    event SymbolicSoulprint(address indexed user, string hash, uint256 weight, address issuedBy, uint256 timestamp);
    event FLBBurned(uint256 amount);
    event ControlledMint(address indexed to, uint256 amount);

    /**
     * @notice Constructor with soulbound initialization
     * @param initialSupply Token amount to mint to deployer (multisig or treasury)
     */
    constructor(uint256 initialSupply) ERC20("Flameborn Token", "FLB") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VALIDATOR_ROLE, msg.sender);
        _grantRole(DAO_ROLE, msg.sender);
        _mint(msg.sender, initialSupply * (10 ** decimals()));
        _soulbound[msg.sender] = true;
        initialMintComplete = true;
    }

    /// 🔒 Soulbound logic: disable transfers
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20)
    {
        if (from != address(0) && to != address(0)) {
            revert("FLB: Token is soulbound and non-transferable");
        }
        super._update(from, to, value);
        if (from == address(0) && to != address(0)) {
            _soulbound[to] = true;
        }
    }

    /// 📇 Register unique African ID hash once per wallet
    function registerAfricanID(string memory idHash) external {
        require(bytes(_africanID[msg.sender]).length == 0, "FLB: ID already registered");
        require(bytes(idHash).length > 0, "FLB: Invalid ID");
        _africanID[msg.sender] = idHash;
        emit AfricanIDRegistered(msg.sender, idHash);
    }

    /// ✅ Validator-controlled minting with audit metadata
    function mintAfterValidation(
        address to,
        uint256 amount,
        string calldata interventionProof
    ) external onlyRole(VALIDATOR_ROLE) {
        require(_isAfrican(to), "FLB: Must be registered African");
        require(amount > 0, "FLB: Zero amount");
        require(bytes(interventionProof).length > 0, "FLB: Missing proof");

        _mint(to, amount);
        emit MintedAfterValidation(to, amount, interventionProof);
    }

    /// 🎓 Incentive minting for youth participation
    function rewardYouthAction(
        address youth,
        uint256 amount,
        string memory actionType
    ) external onlyRole(YOUTH_ROLE) {
        require(_isAfrican(youth), "FLB: Must be African youth");
        require(amount > 0, "FLB: Zero reward");
        require(bytes(actionType).length > 0, "FLB: Action required");

        _mint(youth, amount);
        emit YouthActionRewarded(youth, amount, actionType);
    }

    /// 🔥 Burn FLB tokens (voluntary)
    function burn(address from, uint256 amount) external onlyRole(DAO_ROLE) {
        _burn(from, amount);
        emit FLBBurned(amount);
    }

    /// 🛠 One-time controlled minting (optional)
    function controlledMint(address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!initialMintComplete, "FLB: Minting closed");
        _mint(to, amount);
        initialMintComplete = true;
        _soulbound[to] = true;
        emit ControlledMint(to, amount);
    }

    /// 🔐 Internal helper: is registered African?
    function _isAfrican(address account) internal view returns (bool) {
        return bytes(_africanID[account]).length > 0;
    }

    /// 📜 Public getter for African ID hash
    function getAfricanID(address account) external view returns (string memory) {
        return _africanID[account];
    }

    /// 🪶 Optional: Symbolic Soulprint mint (hookable by DAO/Oracle)
    function issueSoulprint(address user, string memory soulHash, uint256 weight)
        external onlyRole(DAO_ROLE)
    {
        require(_isAfrican(user), "FLB: Not verified African");
        require(bytes(soulHash).length > 0, "FLB: Invalid soul hash");
        emit SymbolicSoulprint(user, soulHash, weight, msg.sender, block.timestamp);
>>>>>>> c9874bb596487dce653a969c1777b6d1101d4a97
    }
}
