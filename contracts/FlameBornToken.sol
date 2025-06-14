// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error InvalidMultisigAddress();
error MintingDisabled();

contract FlamebornToken is ERC20, AccessControl {
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");
    uint256 public constant INITIAL_SUPPLY = 100 * 10 ** 18;
    bool public initialMintComplete;

    constructor(address multisigWallet) ERC20("Flameborn", "FLB") {
        if (multisigWallet == address(0)) revert InvalidMultisigAddress();

        _grantRole(DEFAULT_ADMIN_ROLE, multisigWallet);
        _grantRole(MULTISIG_ROLE, multisigWallet);

        _mint(multisigWallet, INITIAL_SUPPLY);
        initialMintComplete = true;
    }

    /// @notice Allows multisig to burn tokens from an address
    function burn(address from, uint256 amount) external onlyRole(MULTISIG_ROLE) {
        _burn(from, amount);
    }

    /// @notice Optional: Controlled mint interface, if future minting allowed
    function controlledMint(address to, uint256 amount) external onlyRole(MULTISIG_ROLE) {
        if (initialMintComplete) revert MintingDisabled();
        _mint(to, amount);
        initialMintComplete = true; // Prevent future mints
    }
}
