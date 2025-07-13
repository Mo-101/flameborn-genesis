// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
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
contract FlameBornTokenV3 is ERC20, ERC20Burnable, AccessControl, EIP712 {
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
        // Regular soulbound check - no transfers between users
        if (from != address(0) && to != address(0)) {
            revert TransferNotAllowed();
        }
        
        // For minting (from == address(0)), require African verification for the recipient
        if (from == address(0) && to != address(0)) {
            // Special case for contract deployment and admin
            if (!hasRole(DEFAULT_ADMIN_ROLE, to) && !isAfricanOrigin(to)) {
                revert NotRegistered();
            }
        }
        
        super._transfer(from, to, value);
        
        // Mark as soulbound when minting
        if (from == address(0) && !_soulbound[to]) {
            _soulbound[to] = true;
        }
    }

    /**
     * @dev Hook that ensures soulbound status after minting.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
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
     */
    function mintAfterValidation(address to, uint256 amount, string calldata proof)
        external
        onlyRole(VALIDATOR_ROLE)
    {
        if (to == address(0)) revert ZeroAddress();
        if (!_isAfrican(to)) revert NotRegistered();
        if (amount == 0) revert ZeroAmount();
        if (bytes(proof).length == 0) revert InvalidProof();

        _mint(to, amount);
        emit MintedAfterValidation(to, amount, proof);
    }

    /**
     * @notice Mint tokens to reward youth participation.
     */
    function rewardYouthAction(address youth, uint256 amount, string calldata action)
        external
        onlyRole(YOUTH_ROLE)
    {
        if (youth == address(0)) revert ZeroAddress();
        if (!_isAfrican(youth)) revert NotRegistered();
        if (amount == 0) revert ZeroAmount();
        if (bytes(action).length == 0) revert InvalidProof();

        // African region bonus (add 10% bonus for continental initiatives)
        string memory regionCode = Strings.toHexString(uint256(keccak256(abi.encodePacked(_africanID[youth]))), 2);
        if (keccak256(abi.encodePacked(regionCode)) == keccak256(abi.encodePacked("0x"))) {
            amount = amount + (amount / 10); // 10% bonus
        }

        _mint(youth, amount);
        emit YouthActionRewarded(youth, amount, action);
    }

    /**
     * @notice Burn tokens from a user.
     */
    function burn(address from, uint256 amount) external onlyRole(DAO_ROLE) {
        if (from == address(0)) revert ZeroAddress();
        _burn(from, amount);
        emit FLBBurned(amount);
    }

    /**
     * @notice One-time minting for ecosystem bootstrapping.
     */
    function controlledMint(address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (to == address(0)) revert ZeroAddress();
        if (initialMintComplete) revert MintClosed();

        _mint(to, amount);
        initialMintComplete = true;
        if (!_soulbound[to]) _soulbound[to] = true;

        emit ControlledMint(to, amount);
    }

    /**
     * @notice Issue symbolic metadata-only soulprint (non-token reward).
     */
    function issueSoulprint(address user, string calldata soulHash, uint256 weight)
        external
        onlyRole(DAO_ROLE)
    {
        if (!_isAfrican(user)) revert NotRegistered();
        if (bytes(soulHash).length == 0) revert InvalidProof();

        emit SymbolicSoulprint(user, soulHash, weight, msg.sender);
    }

    /**
     * @notice Get registered African ID hash.
     */
    function getAfricanID(address account) external view returns (string memory idHash) {
        idHash = _africanID[account];
    }
    
    /**
     * @notice Check if an address has been verified as African origin
     * @param user Address to check
     * @return verified Whether the address is verified as African
     */
    function isAfricanOrigin(address user) public view returns (bool) {
        return _africanVerified[user];
    }
    
    /**
     * @notice Get verification method used for an address
     * @param user Address to check
     * @return method Verification method used
     */
    function getVerificationMethod(address user) external view returns (VerificationType) {
        return _verificationMethod[user];
    }
    
    /**
     * @notice Verify African origin through tribal council approval
     * @param user Address to verify
     * @param africanIdHash African ID hash for the user
     */
    function verifyByTribalCouncil(address user, string calldata africanIdHash) 
        external 
        onlyRole(TRIBAL_COUNCIL_ROLE)
    {
        if (user == address(0)) revert ZeroAddress();
        if (bytes(africanIdHash).length == 0) revert InvalidProof();
        
        _africanID[user] = africanIdHash;
        _africanVerified[user] = true;
        _verificationMethod[user] = VerificationType.TRIBAL_COUNCIL;
        _verificationTimestamp[user] = block.timestamp;
        
        emit AfricanIdentityVerified(user, VerificationType.TRIBAL_COUNCIL);
    }
    
    /**
     * @notice Approve a biometric hash for verification
     * @param biometricHash Hash of approved biometric data
     */
    function approveBiometricHash(bytes32 biometricHash) 
        external 
        onlyRole(VALIDATOR_ROLE) 
    {
        if (biometricHash == bytes32(0)) revert InvalidProof();
        
        _approvedBiometricHashes[biometricHash] = true;
        emit BiometricHashApproved(biometricHash);
    }
    
    /**
     * @notice Revoke an approved biometric hash
     * @param biometricHash Hash to revoke
     */
    function revokeBiometricHash(bytes32 biometricHash) 
        external 
        onlyRole(VALIDATOR_ROLE) 
    {
        if (biometricHash == bytes32(0)) revert InvalidProof();
        
        _approvedBiometricHashes[biometricHash] = false;
        emit BiometricHashRevoked(biometricHash);
    }
    
    /**
     * @notice Verify African origin through biometric proof
     * @param africanIdHash African ID hash for the user
     * @param biometricHash Biometric data hash
     * @param signature Validator signature
     */
    function verifyByBiometric(
        string calldata africanIdHash,
        bytes32 biometricHash,
        bytes calldata signature
    ) external {
        if (bytes(africanIdHash).length == 0) revert InvalidProof();
        if (biometricHash == bytes32(0)) revert InvalidProof();
        
        // Verify the biometric hash is approved
        if (!_approvedBiometricHashes[biometricHash]) revert InvalidProof();
        
        // Verify validator signature
        bytes32 message = keccak256(abi.encodePacked(msg.sender, biometricHash, africanIdHash));
        bytes32 ethSignedHash = ECDSA.toEthSignedMessageHash(message);
        address signer = ECDSA.recover(ethSignedHash, signature);
        
        // Confirm signer is a validator
        if (!hasRole(VALIDATOR_ROLE, signer)) revert InvalidProof();
        
        // Register verification
        _africanID[msg.sender] = africanIdHash;
        _africanVerified[msg.sender] = true;
        _verificationMethod[msg.sender] = VerificationType.BIOMETRIC;
        _verificationTimestamp[msg.sender] = block.timestamp;
        
        emit AfricanIdentityVerified(msg.sender, VerificationType.BIOMETRIC);
    }
    
    /**
     * @notice Verify African origin through ancestry proof
     * @param user Address to verify
     * @param africanIdHash African ID hash for the user
     * @param ancestryProof Proof of African ancestry
     */
    function verifyByAncestryProof(
        address user,
        string calldata africanIdHash,
        bytes calldata ancestryProof
    ) external onlyRole(ELDER_ROLE) {
        if (user == address(0)) revert ZeroAddress();
        if (bytes(africanIdHash).length == 0) revert InvalidProof();
        if (ancestryProof.length == 0) revert InvalidProof();
        
        // In production, this would verify a zero-knowledge proof
        // For now, we trust the elder's verification
        
        _africanID[user] = africanIdHash;
        _africanVerified[user] = true;
        _verificationMethod[user] = VerificationType.ANCESTRY_PROOF;
        _verificationTimestamp[user] = block.timestamp;
        
        emit AfricanIdentityVerified(user, VerificationType.ANCESTRY_PROOF);
    }

    /**
     * @notice Returns number of decimals (18).
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /**
     * @dev Check if a user has registered and verified their African ID.
     */
    function _isAfrican(address user) internal view returns (bool) {
        return bytes(_africanID[user]).length != 0 && _africanVerified[user];
    }
}
