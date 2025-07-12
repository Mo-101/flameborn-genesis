// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Lock {
    uint256 public unlockTime;
    address payable public owner;

    event Withdrawal(uint256 amount, uint256 when);

    // Custom errors for gas optimization
    error UnlockTimeInPast();
    error WithdrawNotReady();
    error NotOwner();

    constructor(uint256 _unlockTime) payable {
        if (block.timestamp >= _unlockTime) revert UnlockTimeInPast();
        unlockTime = _unlockTime;
        owner = payable(msg.sender);
    }

    function withdraw() public {
        // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

        if (block.timestamp < unlockTime) revert WithdrawNotReady();
        if (msg.sender != owner) revert NotOwner();

        emit Withdrawal(address(this).balance, block.timestamp);

        owner.transfer(address(this).balance);
    }
}
