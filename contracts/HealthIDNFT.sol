// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract HealthIDNFT is ERC721URIStorage, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");

    constructor(address admin) ERC721("HealthIDNFT", "HEALTH") {
        require(admin != address(0), "Admin required");
        
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MULTISIG_ROLE, msg.sender);
    }
    
    function approve(
        address /* spender */,
        uint256 /* tokenId */
    ) public override(ERC721, IERC721) pure {
        revert("Soulbound: approval not allowed");
    }
    
    function transferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        require(from == msg.sender || _isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        _transfer(from, to, tokenId);
    }
    
    function setApprovalForAll(
        address /* operator */,
        bool /* approved */
    ) public override(ERC721, IERC721) pure {
        revert("Soulbound: approval not allowed");
    }
    
    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        safeTransferFrom(from, to, tokenId, "");
    }
    
    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId, 
        bytes memory data
    ) public override(ERC721, IERC721) {
        require(from == msg.sender || _isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        _safeTransfer(from, to, tokenId, data);
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721URIStorage, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    function mint(address to, uint256 tokenId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, tokenId);
    }
    
    /** @dev Creates a token with metadata URI and mints it. */
    function mintWithMetadata(address to, uint256 tokenId, string memory metadataURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, tokenId);
        _setTokenURI(tokenId, metadataURI);
    }
}