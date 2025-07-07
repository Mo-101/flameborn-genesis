// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title FlameBornToken (Soulbound ERC20)
 * @dev Non-transferable (soulbound) ERC20 with custom roles and African identity enforcement.
 * - DAO_ROLE is core for on-chain governance and funding of African health/youth projects.
 * - Transfers are permanently disabled (except mint/burn by validators).
 * - All important actions (mint, African ID registration, youth reward) emit events for analytics.
 */
contract FlameBornToken is ERC20, AccessControl {
    // === Roles ===
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");
    bytes32 public constant YOUTH_ROLE = keccak256("YOUTH_ROLE");

    // === Soulbound and ID Storage ===
    mapping(address => bool) private _soulbound;
    mapping(address => string) private _africanID;

    // === Events ===
    event AfricanIDRegistered(address indexed account, string idHash);
    event MintedAfterValidation(address indexed to, uint256 amount, string interventionProof);
    event YouthActionRewarded(address indexed youth, uint256 amount, string actionType);

    /**
     * @dev Initializes the FLB token.
     * - Sets admin, validator, DAO roles to deployer.
     * - Mints genesis supply to deployer (who becomes soulbound).
     */
    constructor(uint256 initialSupply) ERC20("Flameborn Token", "FLB") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VALIDATOR_ROLE, msg.sender);
        _grantRole(DAO_ROLE, msg.sender);
        _mint(msg.sender, initialSupply * (10 ** decimals())); // Standard: 18 decimals
        _soulbound[msg.sender] = true;
    }

    /**
     * @dev Override ERC20/AccessControl update to enforce soulbound logic.
     * - Blocks all transfers (except mint and burn).
     * - Mints make the recipient soulbound forever.
     */
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
        // NOTE: Burning does NOT reset soulbound status (intentional).
    }

    /**
     * @dev Register an African ID (hash) for caller, only once.
     * Emits AfricanIDRegistered.
     */
    function registerAfricanID(string memory idHash) external {
        require(bytes(_africanID[msg.sender]).length == 0, "FLB: African ID already registered");
        require(bytes(idHash).length > 0, "FLB: ID hash cannot be empty");
        _africanID[msg.sender] = idHash;
        emit AfricanIDRegistered(msg.sender, idHash);
    }

    /**
     * @dev Validator mints FLB after validating an intervention (requires African recipient).
     * Emits MintedAfterValidation.
     */
    function mintAfterValidation(
        address to,
        uint256 amount,
        string calldata interventionProof
    ) external onlyRole(VALIDATOR_ROLE) {
        require(_isAfrican(to), "FLB: Only African recipients allowed");
        require(amount > 0, "FLB: Mint amount must be greater than zero");
        require(bytes(interventionProof).length > 0, "FLB: Intervention proof cannot be empty");

        _mint(to, amount);
        emit MintedAfterValidation(to, amount, interventionProof);
    }

    /**
     * @dev Internal helper: checks if address has registered an African ID.
     */
    function _isAfrican(address account) internal view returns (bool) {
        return bytes(_africanID[account]).length > 0;
    }

    /**
     * @dev Youth reward. YOUTH_ROLE only. Must be African, logs action.
     * Emits YouthActionRewarded.
     */
    function rewardYouthAction(
        address youth,
        uint256 amount,
        string memory actionType
    ) external onlyRole(YOUTH_ROLE) {
        require(_isAfrican(youth), "FLB: Only African youth can be rewarded");
        require(amount > 0, "FLB: Reward amount must be greater than zero");
        require(bytes(actionType).length > 0, "FLB: Action type cannot be empty");

        _mint(youth, amount);
        emit YouthActionRewarded(youth, amount, actionType);
    }

    /**
     * @dev Get registered African ID hash for an address.
     */
    function getAfricanID(address account) external view returns (string memory) {
        return _africanID[account];
    }
}
