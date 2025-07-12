// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Thrown if the multisig wallet address is not valid (zero address).
error InvalidMultisigAddress();

/// @notice Thrown if minting is attempted after the initial mint is complete.
error MintingDisabled();

/// @title FlamebornToken (FLB)
/// @notice Core currency of the FlameBorn ecosystem. Controlled via multisig.
/// @dev Extends OpenZeppelin ERC20 + AccessControl
contract FlamebornToken is ERC20, AccessControl {
    /// @notice Role allowing controlled minting/burning
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");

    /// @notice Initial token supply: 100 FLB
    uint256 public constant INITIAL_SUPPLY = 100 * 10 ** 18;

    /// @notice Flag that disables further minting after initial mint
    bool private _initialMintComplete;

    /// @notice Returns whether the initial mint has been completed
    function initialMintComplete() external view returns (bool) {
        return _initialMintComplete;
    }

    /// @notice Deploys the token and performs initial mint to multisig wallet
    /// @param multisigWallet The address that will receive the initial supply and hold admin rights
    constructor(address multisigWallet) ERC20("Flameborn", "FLB") {
        if (multisigWallet == address(0)) revert InvalidMultisigAddress();

        _grantRole(DEFAULT_ADMIN_ROLE, multisigWallet);
        _grantRole(MULTISIG_ROLE, multisigWallet);

        _mint(multisigWallet, INITIAL_SUPPLY);
        _initialMintComplete = true;
    }

    /// @notice Allows the multisig to burn tokens from a given address
    /// @param from The address whose tokens will be burned
    /// @param amount The amount of tokens to burn
    function burn(address from, uint256 amount) external onlyRole(MULTISIG_ROLE) {
        _burn(from, amount);
    }

    /// @notice (One-time) mint function if future minting is required before lock
    /// @param to The address to receive minted tokens
    /// @param amount The amount of tokens to mint
    function controlledMint(address to, uint256 amount) external onlyRole(MULTISIG_ROLE) {
        if (_initialMintComplete) revert MintingDisabled();

        _mint(to, amount);
        _initialMintComplete = true; // Permanently lock future minting
    }
}
