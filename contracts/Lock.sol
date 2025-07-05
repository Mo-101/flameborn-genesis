// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Lock {
    uint256 public unlockTime;
    address payable public owner;

    event Withdrawal(uint amount, uint when);

    error UnlockTimeNotInFuture();
    constructor(uint256 _unlockTime) payable {
        require(block.timestamp < _unlockTime, "Unlock time in future");
        if (block.timestamp >= _unlockTime) revert UnlockTimeNotInFuture();
        unlockTime = _unlockTime;
        owner = payable(msg.sender);
    }

    error WithdrawNotReady();
    error NotOwner();
    function withdraw() public {
        // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

        if (block.timestamp < unlockTime) revert WithdrawNotReady();
        if (msg.sender != owner) revert NotOwner();

        emit Withdrawal(address(this).balance, block.timestamp);

        owner.transfer(address(this).balance);
    }
}
