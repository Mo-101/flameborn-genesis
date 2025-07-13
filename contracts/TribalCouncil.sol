// SPDX-License-Identifier: KAIRO-COVENANT-v1
pragma solidity ^0.8.24;

/**
 * @title TribalCouncil
 * @notice Multisig interface for tribal council members to verify users
 * @dev Requires a threshold of signatures to confirm a user's origin
 */
contract TribalCouncil {
    address[] public elders;
    uint public threshold;
    
    // Proposal tracking
    struct Proposal {
        address target;
        bytes data;
        bool executed;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    
    Proposal[] public proposals;
    
    // Events
    event ProposalCreated(uint indexed id, address indexed creator, address target);
    event ProposalApproved(uint indexed id, address indexed elder);
    event ProposalExecuted(uint indexed id);
    event ElderAdded(address indexed elder);
    event ElderRemoved(address indexed elder);
    event ThresholdChanged(uint oldThreshold, uint newThreshold);
    
    constructor(address[] memory _elders, uint _threshold) {
        require(_threshold <= _elders.length, "Invalid threshold");
        require(_threshold > 0, "Threshold must be greater than zero");
        elders = _elders;
        threshold = _threshold;
        
        for(uint i = 0; i < _elders.length; i++) {
            emit ElderAdded(_elders[i]);
        }
    }
    
    modifier onlyElder() {
        require(isElder(msg.sender), "Unauthorized: Not an elder");
        _;
    }
    
    modifier onlySelf() {
        require(msg.sender == address(this), "Only via proposal");
        _;
    }
    
    // Create governance proposal
    function propose(address _target, bytes calldata _data) external onlyElder returns (uint) {
        uint proposalId = proposals.length;
        
        Proposal storage newProposal = proposals.push();
        newProposal.target = _target;
        newProposal.data = _data;
        newProposal.executed = false;
        newProposal.approvalCount = 0;
        
        emit ProposalCreated(proposalId, msg.sender, _target);
        return proposalId;
    }
    
    // Approve proposal
    function approve(uint proposalId) external onlyElder {
        require(proposalId < proposals.length, "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");
        require(!proposal.approvals[msg.sender], "Already approved");
        
        proposal.approvals[msg.sender] = true;
        proposal.approvalCount++;
        
        emit ProposalApproved(proposalId, msg.sender);
    }
    
    // Execute approved proposal
    function execute(uint proposalId) external onlyElder {
        require(proposalId < proposals.length, "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];
        require(proposal.approvalCount >= threshold, "Insufficient approvals");
        require(!proposal.executed, "Already executed");
        
        proposal.executed = true;
        
        (bool success, ) = proposal.target.call(proposal.data);
        require(success, "Execution failed");
        
        emit ProposalExecuted(proposalId);
    }
    
    // Elder verification
    function isElder(address _address) public view returns (bool) {
        for(uint i = 0; i < elders.length; i++) {
            if(elders[i] == _address) return true;
        }
        return false;
    }
    
    // Add new elder
    function addElder(address newElder) external onlySelf {
        require(newElder != address(0), "Invalid address");
        require(!isElder(newElder), "Already an elder");
        
        elders.push(newElder);
        emit ElderAdded(newElder);
    }
    
    // Remove an elder
    function removeElder(address oldElder) external onlySelf {
        require(isElder(oldElder), "Not an elder");
        require(elders.length > threshold, "Cannot reduce elders below threshold");
        
        uint index;
        for(uint i = 0; i < elders.length; i++) {
            if(elders[i] == oldElder) {
                index = i;
                break;
            }
        }
        
        // Swap with the last element and pop
        elders[index] = elders[elders.length - 1];
        elders.pop();
        
        emit ElderRemoved(oldElder);
    }
    
    // Update threshold
    function updateThreshold(uint newThreshold) external onlySelf {
        require(newThreshold > 0, "Threshold must be positive");
        require(newThreshold <= elders.length, "Threshold exceeds elder count");
        
        uint oldThreshold = threshold;
        threshold = newThreshold;
        emit ThresholdChanged(oldThreshold, newThreshold);
    }
    
    // Get all elders
    function getElders() external view returns (address[] memory) {
        return elders;
    }
    
    // Get proposal count
    function getProposalCount() external view returns (uint) {
        return proposals.length;
    }
}
