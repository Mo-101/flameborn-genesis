// SPDX-License-Identifier: KAIRO-COVENANT-v1
pragma solidity ^0.8.24;

import "./TribalCouncil.sol";
import "./AfricanOriginProof.sol";

/**
 * @title ZKProofRegistry
 * @notice Zero-Knowledge Ancestry Verification
 * @dev Manages zero-knowledge proofs for verifying African ancestry without exposing raw data
 */
contract ZKProofRegistry {
    TribalCouncil public tribalCouncil;
    AfricanOriginProof public originProof;
    
    // Registered proofs
    mapping(bytes32 => bool) public proofRegistry;
    
    // User verifications
    mapping(address => bytes32) public userProofs;
    
    // Proof verification events
    event ProofTemplateRegistered(bytes32 indexed proofHash, address elder);
    event OriginVerified(address indexed user, bytes32 proofHash);
    
    constructor(address _tribalCouncil, address _originProof) {
        tribalCouncil = TribalCouncil(_tribalCouncil);
        originProof = AfricanOriginProof(_originProof);
    }
    
    /**
     * @notice Register new ZK proof template
     * @param proofHash Hash of the proof template
     * @param councilApproval Tribal council approval signature
     */
    function registerProofTemplate(
        bytes32 proofHash,
        bytes calldata councilApproval
    ) external {
        require(proofHash != bytes32(0), "Invalid proof hash");
        require(!proofRegistry[proofHash], "Template already registered");
        
        // Verify tribal council approval
        require(tribalCouncil.isElder(msg.sender), "Only elders can register");
        
        // In production: Verify multisig signature
        proofRegistry[proofHash] = true;
        emit ProofTemplateRegistered(proofHash, msg.sender);
    }
    
    /**
     * @notice Verify user origin via ZK proof
     * @param user Address of the user being verified
     * @param proofHash Hash of the proof template
     * @param zkProof Zero-knowledge proof data
     */
    function verifyOrigin(
        address user,
        bytes32 proofHash,
        bytes calldata zkProof
    ) external {
        require(user != address(0), "Invalid user address");
        require(proofRegistry[proofHash], "Unregistered proof type");
        require(zkProof.length > 0, "Empty proof");
        
        // In production: Implement actual ZK-SNARK verification
        // This would interface with a ZK verifier contract
        
        // For demo: Simple hash verification
        bytes32 computedHash = keccak256(abi.encodePacked(user, zkProof));
        require(computedHash == proofHash, "Proof mismatch");
        
        // Record the verification
        userProofs[user] = proofHash;
        
        // Register with origin proof contract
        bytes memory signature = zkProof;
        originProof.registerZKProof(proofHash, signature);
        
        emit OriginVerified(user, proofHash);
    }
    
    /**
     * @notice Check if user has verified their African origin
     * @param user Address to check
     * @return verified Whether the user is verified
     */
    function isVerified(address user) external view returns (bool verified) {
        return userProofs[user] != bytes32(0);
    }
    
    /**
     * @notice Get proof hash for a user
     * @param user Address to check
     * @return proofHash Hash of the user's proof
     */
    function getUserProof(address user) external view returns (bytes32 proofHash) {
        return userProofs[user];
    }
    
    /**
     * @notice Check if a proof template is registered
     * @param proofHash Hash to check
     * @return registered Whether the proof template is registered
     */
    function isProofTemplateRegistered(bytes32 proofHash) external view returns (bool registered) {
        return proofRegistry[proofHash];
    }
}
