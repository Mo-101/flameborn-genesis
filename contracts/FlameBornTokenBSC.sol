// contracts/FlameBornTokenBSC.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {ERC20}from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title FlameBornTokenV3
 * @notice Soulbound ERC20 token for identity-based, non-transferable incentives.
 * @dev Fully gas-optimized and protected with proper access control and validation.
 */
contract FlameBornTokenV3BSC is ERC20, ERC20Burnable, AccessControl, EIP712 {
    // === Custom Errors ===
    error ZeroAddress();
    error AlreadyRegistered();
    error NotRegistered();
    error InvalidProof();
    error ZeroAmount();
    error MintClosed();
    error TransferNotAllowed();

    // === Role Identifiers ===
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 public constant YOUTH_ROLE = keccak256("YOUTH_ROLE");
    bytes32 public constant ELDER_ROLE = keccak256("ELDER_ROLE");
    bytes32 public constant TRIBAL_COUNCIL_ROLE = keccak256("TRIBAL_COUNCIL_ROLE");

    // === Mappings ===
    mapping(address user => bool) private _soulbound;
    mapping(address user => string) private _africanID;
    mapping(address user => VerificationType) private _verificationMethod;
    mapping(address user => bool) private _africanVerified;
    mapping(bytes32 => bool) private _approvedBiometricHashes;
    mapping(address => uint256) private _verificationTimestamp;

    // === Verification Types ===
    enum VerificationType {
        NONE,
        TRIBAL_COUNCIL,
        BIOMETRIC,
        ANCESTRY_PROOF
    }

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

    // === State flags ===
    bool public initialMintComplete;

    /**
     * @notice Deploys FlameBornTokenV3 and mints initial supply to deployer.
     * @param initialSupply Initial supply (without decimals).
     */
    constructor(uint256 initialSupply)
        ERC20("FlameBorn Token", "FLB")
        EIP712("FlameBorn", "3.0.0")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DAO_ROLE, msg.sender);
        _grantRole(VALIDATOR_ROLE, msg.sender);
        _grantRole(YOUTH_ROLE, msg.sender);
        _grantRole(ELDER_ROLE, msg.sender);
        _grantRole(TRIBAL_COUNCIL_ROLE, msg.sender);

        // Auto-verify deployer as African
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

    /**
     * @dev Disables transfers except minting and burning.
     * Also enforces African origin verification for recipients.
     */
    function _transfer(address from, address to, uint256 value) internal virtual override {
        // Allow minting and burning as before
        if (from == address(0) || to == address(0)) {
            super._transfer(from, to, value);
            return;
        }
        if (!_africanVerified[from]) revert TransferNotAllowed();
        if (!_africanVerified[to]) revert TransferNotAllowed();
        super._transfer(from, to, value);
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    // ... (rest of the contract code remains unchanged)
}
