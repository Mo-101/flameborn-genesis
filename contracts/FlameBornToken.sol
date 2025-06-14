// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts@4.9.3/access/AccessControl.sol";
import "@openzeppelin/contracts@4.9.3/token/ERC20/ERC20.sol";

contract FlamebornToken is ERC20, AccessControl {
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");
    bool private _initialMintComplete;

    constructor(address multisigWallet) ERC20("Flameborn", "FLB") {
        require(multisigWallet != address(0), "Invalid multisig address");
        
        _grantRole(DEFAULT_ADMIN_ROLE, multisigWallet);
        _grantRole(MULTISIG_ROLE, multisigWallet);
        
        _mint(multisigWallet, 100 * 10**decimals());
        _initialMintComplete = true;
    }

    // Fixed parameters with names
    function _mint(address account, uint256 amount) internal virtual override {
        require(!_initialMintComplete, "Minting disabled permanently");
        super._mint(account, amount);
    }

    function burn(address from, uint256 amount) external onlyRole(MULTISIG_ROLE) {
        _burn(from, amount);
    }
}
