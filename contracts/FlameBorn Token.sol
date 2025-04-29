// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract FlamebornToken is ERC20, AccessControl {
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");
    error FixedSupply();

    constructor(address multisigWallet) ERC20("Flameborn", "FLB") {
        _grantRole(DEFAULT_ADMIN_ROLE, multisigWallet);
        _grantRole(MULTISIG_ROLE, multisigWallet);
        _mint(multisigWallet, 1_000_000 * 10**18);
    }

    function mint(address, uint256) external view onlyRole(MULTISIG_ROLE) {
        revert FixedSupply();
    }
}