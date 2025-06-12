// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Upgrade.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract HealthIDNFT is ERC721URIStorage, AccessControl {
bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

constructor(address admin) virtual{
require(admin != address(0), "Admin required");

_grantRole(DEFAULT_ADMIN_ROLE,address(this));
// Create a custom MULTISIG_ROLE for controlling token burns through this contract.
_setRole(MULTISIG_ROLE,msg.sender);

}
function approve(
address spender,
uint256 tokenId
) public pure override returns (bool){
revert("Soulbound: approval not allowed");
}
function transferFrom(address from, address to,uint256 tokenId)
external virtual override(ERC721URIStorage, AccessControl){

require(from == msg.sender || isApprovedOrOwner(msg.sender,tokenId),"Not approved or owner");

_transferFrom(from,to,tokenId);
}

function setApprovalForAll(
address operator,
bool isapproved
) public pure returns (bool){
revert("Soulbound: approval not allowed");
}

function safeTransferFrom(address from,address to,uint256 tokenId)
external virtual override(ERC721URIStorage, AccessControl){

require(from == msg.sender || isApprovedOrOwner(msg.sender,tokenId),"Not approved or owner");

_safeTransferFrom(from,to,tokenId);
}

function supportsInterface(bytes4 interfaceId) public view returns (bool){
return super.supportsInterface(interfaceId);

}

function mint(address to,uint256 tokenId ) external {
require(hasRole(DEFAULT_ADMIN_ROLE,address(this)), "Only the creator of HealthIDNFT can mint" );

_mint(to,tokenId);
}

function hasRole(bytes32 role,address account) internal view returns (bool){
return super.hasRole(role,account);

}

/** @dev Creates a token with metadata URI and mints it. */
function mint(address to,uint256 tokenId,string memory metadataURI ) external {
require(
hasRole(DEFAULT_ADMIN_ROLE,address(this)),
"Only the creator of HealthIDNFT can mint"
);

_mint(to,tokenId);
}
}