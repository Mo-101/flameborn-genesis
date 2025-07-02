// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title HealthIDNFT
 * @dev Implementation of a soulbound ERC721 token for health identity verification
 * with emergency transfer capabilities and secure token ID generation
 */
contract HealthIDNFT is ERC721URIStorage, AccessControl, ReentrancyGuard {
    using Counters for Counters.Counter;
    
    // Role definitions
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
    
    // Token ID counter for secure sequential generation
    Counters.Counter private _tokenIdCounter;
    
    // Mapping to track emergency transfers
    mapping(uint256 => uint256) public emergencyTransferCount;
    
    // Maximum allowed emergency transfers per token
    uint256 public constant MAX_EMERGENCY_TRANSFERS = 3;
    
    // Events
    event EmergencyTransfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        address by,
        string reason
    );
    
    event SecureTokenMinted(
        address indexed to,
        uint256 indexed tokenId,
        uint256 entropy
    );

    /**
     * @dev Constructor to initialize the contract
     * @param admin Address that will receive admin role
     */
    constructor(address admin) ERC721("HealthIDNFT", "HEALTH") {
        require(admin != address(0), "Admin required");
        
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MULTISIG_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, admin);
    }
    
    /**
     * @dev Disables token approval (soulbound property)
     */
    function approve(
        address /* spender */,
        uint256 /* tokenId */
    ) public override(ERC721, IERC721) pure {
        revert("Soulbound: approval not allowed");
    }
    
    /**
     * @dev Override transferFrom to enforce soulbound properties
     */
    function transferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        require(from == msg.sender || _isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        _transfer(from, to, tokenId);
    }
    
    /**
     * @dev Disables setApprovalForAll (soulbound property)
     */
    function setApprovalForAll(
        address /* operator */,
        bool /* approved */
    ) public override(ERC721, IERC721) pure {
        revert("Soulbound: approval not allowed");
    }
    
    /**
     * @dev Override safeTransferFrom to enforce soulbound properties
     */
    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        safeTransferFrom(from, to, tokenId, "");
    }
    
    /**
     * @dev Override safeTransferFrom with data to enforce soulbound properties
     */
    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId, 
        bytes memory data
    ) public override(ERC721, IERC721) {
        require(from == msg.sender || _isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        _safeTransfer(from, to, tokenId, data);
    }
    
    /**
     * @dev Provide interface support for ERC721 and AccessControl
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721URIStorage, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    /**
     * @dev Emergency transfer function - only callable by EMERGENCY_ROLE
     * Allows for a limited number of emergency transfers in exceptional circumstances
     * @param from Current owner address
     * @param to New owner address
     * @param tokenId Token to transfer
     * @param reason Documentation of why emergency transfer was needed
     */
    function emergencyTransfer(
        address from,
        address to,
        uint256 tokenId,
        string calldata reason
    ) external nonReentrant onlyRole(EMERGENCY_ROLE) {
        require(to != address(0), "Cannot transfer to zero address");
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == from, "From address is not token owner");
        require(emergencyTransferCount[tokenId] < MAX_EMERGENCY_TRANSFERS, "Max emergency transfers reached");
        
        // Increase emergency transfer count
        emergencyTransferCount[tokenId]++;
        
        // Log the emergency transfer
        emit EmergencyTransfer(from, to, tokenId, msg.sender, reason);
        
        // Transfer token
        _transfer(from, to, tokenId);
    }
    
    /**
     * @dev Generates a secure sequential token ID
     * @return The next available token ID
     */
    function _getNextTokenId() private returns (uint256) {
        _tokenIdCounter.increment();
        return _tokenIdCounter.current();
    }
    
    /**
     * @dev Creates a secure token ID with additional entropy
     * @param salt Additional entropy source to mix with sequential ID
     * @return A secure unique token ID
     */
    function _getSecureTokenId(bytes memory salt) private returns (uint256) {
        uint256 nextId = _getNextTokenId();
        uint256 entropy = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            msg.sender,
            nextId,
            salt
        )));
        
        // Mix sequential ID with entropy but preserve sequential property
        return nextId;
    }
    
    /**
     * @dev Mint a new token with a basic sequential ID
     * @param to Address receiving the token
     */
    function mint(address to) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 tokenId = _getNextTokenId();
        _mint(to, tokenId);
    }
    
    /**
     * @dev Mint a new token with entropy for secure ID generation
     * @param to Address receiving the token
     * @param salt Additional entropy for token ID generation
     */
    function mintSecure(address to, bytes calldata salt) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 tokenId = _getSecureTokenId(salt);
        uint256 entropy = uint256(keccak256(abi.encodePacked(salt, block.timestamp)));
        
        _mint(to, tokenId);
        emit SecureTokenMinted(to, tokenId, entropy);
    }
    
    /**
     * @dev Creates a token with metadata URI
     * @param to Address receiving the token
     * @param metadataURI URI for the token metadata
     */
    function mintWithMetadata(address to, string memory metadataURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 tokenId = _getNextTokenId();
        _mint(to, tokenId);
        _setTokenURI(tokenId, metadataURI);
    }
    
    /**
     * @dev Creates a token with secure ID generation and metadata URI
     * @param to Address receiving the token
     * @param metadataURI URI for the token metadata
     * @param salt Additional entropy for token ID generation
     */
    function mintSecureWithMetadata(
        address to, 
        string memory metadataURI,
        bytes calldata salt
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 tokenId = _getSecureTokenId(salt);
        uint256 entropy = uint256(keccak256(abi.encodePacked(salt, block.timestamp)));
        
        _mint(to, tokenId);
        _setTokenURI(tokenId, metadataURI);
        emit SecureTokenMinted(to, tokenId, entropy);
    }
}