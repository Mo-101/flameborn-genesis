// contracts/StakeholderRegistry.sol
 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


abstract contract IStakeholderRegistry {
    function stakeholders(address token) external view returns (uint256 count);
}
/**
 * @title LearnToEarn
 * @dev Users claim FLB tokens by completing verified courses.
 */
contract LearnToEarn is Ownable {
    IERC20 public flbToken;
    bytes32 public merkleRoot;

    mapping(address => bool) public hasClaimed;

    event FLBClaimed(address indexed user, uint256 amount);

    constructor(address _flbToken, bytes32 _merkleRoot) {
        flbToken = IERC20(_flbToken);
        merkleRoot = _merkleRoot;
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(!hasClaimed[msg.sender], "Already claimed");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");

        hasClaimed[msg.sender] = true;
        require(flbToken.transfer(msg.sender, amount), "Transfer failed");

        emit FLBClaimed(msg.sender, amount);
    }

    function updateMerkleRoot(bytes32 newRoot) external onlyOwner {
        merkleRoot = newRoot;
    }
}

