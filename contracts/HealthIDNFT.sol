// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract HealthIDNFT is ERC721URIStorage, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");

    error AdminRequired();
    error SoulboundApprovalNotAllowed();
    error SoulboundSetApprovalForAllNotAllowed();
    error NotApprovedOrOwner();

    constructor(address admin) ERC721("HealthIDNFT", "HEALTH") {
        if (admin == address(0)) revert AdminRequired();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MULTISIG_ROLE, msg.sender);
    }
    
    /// @dev Disallow approvals to enforce soulbound property
    function approve(
        address /* spender */,
        uint256 /* tokenId */
    ) public override(ERC721, IERC721) pure {
        revert SoulboundApprovalNotAllowed();
    }
    
    /// @dev Disallow approvals for all to enforce soulbound property
    function setApprovalForAll(
        address /* operator */,
        bool /* approved */
    ) public override(ERC721, IERC721) pure {
        revert SoulboundSetApprovalForAllNotAllowed();
    }
    
    /// @dev Only allow transfer if sender is owner or approved (should be disabled for true soulbound)
    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId, 
        bytes memory data
    ) public override(ERC721, IERC721) {
        if (!(from == msg.sender || getApproved(tokenId) == msg.sender || isApprovedForAll(from, msg.sender))) revert NotApprovedOrOwner();
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