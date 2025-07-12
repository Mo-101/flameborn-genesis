// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FLBVesting {
    using SafeMath for uint256;

    IERC20 public token;
    address public beneficiary;
    uint256 public start;
    uint256 public cliff;
    uint256 public duration;
    uint256 public released;

    constructor(
        address _token,
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration
    ) {
        token = IERC20(_token);
        beneficiary = _beneficiary;
        start = _start;
        cliff = _start + _cliff;
        duration = _duration;
    }

    function release() public {
        require(block.timestamp >= cliff, "Too early");
        uint256 unreleased = vestedAmount() - released;
        require(unreleased > 0, "Nothing to release");

        released = released.add(unreleased);
        token.transfer(beneficiary, unreleased);
    }

    function vestedAmount() public view returns (uint256) {
        uint256 totalBalance = token.balanceOf(address(this)) + released;

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start + duration) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp - start).div(duration);
        }
    }
}
