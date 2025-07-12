// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title FlameBornToken (Soulbound ERC20)
 * @dev Non-transferable (soulbound) ERC20 with roles for validators, DAO, and youth incentive.
 * - Transfers disabled permanently (soulbound).
 * - African ID registration tied to mint eligibility.
 * - Integrated with analytics events and social impact tracking.
 */

/// @notice Custom errors for gas optimization
error SoulboundToken();
error IdAlreadyRegistered();
error InvalidId();
error NotAfrican();
error ZeroAmount();
error MissingProof();
error AfricanYouthRequired();
error ActionRequired();
error MintingClosed();
error InvalidSoulHash();
contract FlameBornToken is ERC20, AccessControl {
    // Chainlink timestamp aggregator (e.g., ETH/USD feed, replace with a timestamp feed if available)
    AggregatorV3Interface public immutable chainlinkTimestamp;

    // NOTE: OpenZeppelin's AccessControl uses mappings for role management, so grantRole, revokeRole, renounceRole, and getRoleAdmin are already gas-optimized and do not use unbounded loops.

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
    constructor(uint256 initialSupply, address _chainlinkTimestamp) ERC20("Flameborn Token", "FLB") {
        if (_chainlinkTimestamp == address(0)) revert InvalidMultisigAddress();
        chainlinkTimestamp = AggregatorV3Interface(_chainlinkTimestamp);
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
            revert SoulboundToken();
        }
        super._update(from, to, value);
        if (from == address(0) && to != address(0)) {
            _soulbound[to] = true;
        }
    }

    /// 📇 Register unique African ID hash once per wallet
    function registerAfricanID(string memory idHash) external {
        if (bytes(_africanID[msg.sender]).length != 0) revert IdAlreadyRegistered();
        if (bytes(idHash).length == 0) revert InvalidId();
        _africanID[msg.sender] = idHash;
        emit AfricanIDRegistered(msg.sender, idHash);
    }

    /// ✅ Validator-controlled minting with audit metadata
    function mintAfterValidation(
        address to,
        uint256 amount,
        string calldata interventionProof
    ) external onlyRole(VALIDATOR_ROLE) {
        if (!_isAfrican(to)) revert NotAfrican();
        if (amount == 0) revert ZeroAmount();
        if (bytes(interventionProof).length == 0) revert MissingProof();

        _mint(to, amount);
        emit MintedAfterValidation(to, amount, interventionProof);
    }

    /// 🎓 Incentive minting for youth participation
    function rewardYouthAction(
        address youth,
        uint256 amount,
        string memory actionType
    ) external onlyRole(YOUTH_ROLE) {
        if (!_isAfrican(youth)) revert AfricanYouthRequired();
        if (amount == 0) revert ZeroAmount();
        if (bytes(actionType).length == 0) revert ActionRequired();

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
        if (initialMintComplete) revert MintingClosed();
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
        if (!_isAfrican(user)) revert NotAfrican();
        if (bytes(soulHash).length == 0) revert InvalidSoulHash();
        (, int256 answer,,,) = chainlinkTimestamp.latestRoundData();
        uint256 timestamp = uint256(answer);
        emit SymbolicSoulprint(user, soulHash, weight, msg.sender, timestamp);
    }
}
