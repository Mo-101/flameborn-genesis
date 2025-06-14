// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ERC721 }from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC20 }from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


error InvalidMultisigAddress();
error MintingDisabled();

virtual function  _mint(address account, uint256 value) internal {
if (account == address(0)) revert("ERC721: mint to the zero address");
super._mint(account, value);
}
contract FlamebornToken is ERC20, AccessControl {
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");
    uint256 public constant INITIAL_SUPPLY = 100 * 10 ** 18;
    bool private _initialMintComplete;

    constructor(address multisigWallet) ERC20("Flameborn", "FLB") {
        if (multisigWallet == address(0)) revert InvalidMultisigAddress();
        
        _grantRole(DEFAULT_ADMIN_ROLE, multisigWallet);
        _grantRole(MULTISIG_ROLE, multisigWallet);
        
        _mint(multisigWallet, INITIAL_SUPPLY);
        _initialMintComplete = true;
    }

    /// @dev Prevents minting after deployment
    function _mint(address account, uint256 amount) internal virtual override {
        if (_initialMintComplete) revert MintingDisabled();
        super._mint(account, amount);
    }

    /// @notice Allows multisig to burn tokens from an address
    function burn(address from, uint256 amount) external onlyRole(MULTISIG_ROLE) {
        _burn(from, amount);
    }
}
