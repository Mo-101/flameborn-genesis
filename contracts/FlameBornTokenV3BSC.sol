// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title FlameBornTokenV3
 * @notice Soulbound ERC20 token for identity-based, non-transferable incentives.
 * @dev Fully gas-optimized and protected with proper access control and validation.
 * @custom:dev-run-script deploy_FLB.js
 */
contract FlameBornTokenV3BSC is ERC20, ERC20Burnable, AccessControl, Pausable, EIP712 {
    // === Constants for Roles ===
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 public constant YOUTH_ROLE = keccak256("YOUTH_ROLE");
    bytes32 public constant ELDER_ROLE = keccak256("ELDER_ROLE");
    bytes32 public constant TRIBAL_COUNCIL_ROLE = keccak256("TRIBAL_COUNCIL_ROLE");

    // === Custom Errors ===
    error ZeroAddress();
    error AlreadyRegistered();
    error NotRegistered();
    error InvalidProof();
    error ZeroAmount();
    error MintClosed();
    error TransferNotAllowed();

    // === Verification Types ===
    enum VerificationType {
        NONE,
        TRIBAL_COUNCIL,
        BIOMETRIC,
        ANCESTRY_PROOF
    }

    // === Mappings ===
    mapping(address => bool) private _soulbound;
    mapping(address => string) private _africanID;
    mapping(address => VerificationType) private _verificationMethod;
    mapping(address => bool) private _africanVerified;
    mapping(bytes32 => bool) private _approvedBiometricHashes;
    mapping(address => uint256) private _verificationTimestamp;

    // === Events ===
    event AfricanIDRegistered(address indexed account, string idHash);
    event MintedAfterValidation(address indexed to, uint256 amount, string proof);
    event YouthActionRewarded(address indexed youth, uint256 amount, string action);
    event SymbolicSoulprint(address indexed user, string hash, uint256 weight, address issuedBy);
    event ControlledMint(address indexed to, uint256 amount);
    event FLBBurned(uint256 amount);
    event AfricanIdentityVerified(address indexed user, VerificationType method);
    event BiometricHashApproved(bytes32 indexed hash);
    event BiometricHashRevoked(bytes32 indexed hash);
    event RoleGrantedLogged(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevokedLogged(bytes32 indexed role, address indexed account, address indexed sender);

    string private _name = "FlameBorn";
    string private _version = "3.0.0";

    bool public initialMintComplete;

    constructor(uint256 initialSupply)
        ERC20("FlameBorn Token", "FLB")
        EIP712(_name, _version)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DAO_ROLE, msg.sender);
        _grantRole(VALIDATOR_ROLE, msg.sender);
        _grantRole(YOUTH_ROLE, msg.sender);
        _grantRole(ELDER_ROLE, msg.sender);
        _grantRole(TRIBAL_COUNCIL_ROLE, msg.sender);

        _africanID[msg.sender] = "FOUNDER_ORIGIN_VERIFIED";
        _africanVerified[msg.sender] = true;
        _verificationMethod[msg.sender] = VerificationType.TRIBAL_COUNCIL;
        _verificationTimestamp[msg.sender] = block.timestamp;
        _soulbound[msg.sender] = true;
        emit AfricanIdentityVerified(msg.sender, VerificationType.TRIBAL_COUNCIL);

        if (initialSupply > 0) {
            _mint(msg.sender, initialSupply * (10 ** decimals()));
        }
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 value) internal virtual override {
        if (from == address(0) || to == address(0)) {
            super._transfer(from, to, value);
            return;
        }
        if (!_africanVerified[from] || !_africanVerified[to]) {
            revert TransferNotAllowed();
        }
        super._transfer(from, to, value);
    }

    function grantRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) {
        super.grantRole(role, account);
        emit RoleGrantedLogged(role, account, msg.sender);
    }

    function revokeRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) {
        super.revokeRole(role, account);
        emit RoleRevokedLogged(role, account, msg.sender);
    }

    function verifyAfricanIdentity(address user, string memory idHash, VerificationType verificationType)
        public onlyRole(VALIDATOR_ROLE)
    {
        if (_africanVerified[user]) revert AlreadyRegistered();
        _africanID[user] = idHash;
        _africanVerified[user] = true;
        _verificationMethod[user] = verificationType;
        _verificationTimestamp[user] = block.timestamp;
        emit AfricanIdentityVerified(user, verificationType);
    }

    function approveBiometricHash(bytes32 hash) public onlyRole(VALIDATOR_ROLE) {
        if (_approvedBiometricHashes[hash]) revert AlreadyRegistered();
        _approvedBiometricHashes[hash] = true;
        emit BiometricHashApproved(hash);
    }

    function revokeBiometricHash(bytes32 hash) public onlyRole(VALIDATOR_ROLE) {
        if (!_approvedBiometricHashes[hash]) revert NotRegistered();
        _approvedBiometricHashes[hash] = false;
        emit BiometricHashRevoked(hash);
    }

    function africanVerified(address user) external view returns (bool) {
        return _africanVerified[user];
    }

    function africanID(address user) external view returns (string memory) {
        return _africanID[user];
    }

    function verificationMethod(address user) external view returns (VerificationType) {
        return _verificationMethod[user];
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
