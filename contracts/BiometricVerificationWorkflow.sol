// SPDX-License-Identifier: KAIRO-COVENANT-v1
pragma solidity ^0.8.24;

import "./AfricanOriginProof.sol";

/**
 * @title BiometricVerificationWorkflow
 * @notice Handles the biometric verification process
 * @dev Interacts with AfricanOriginProof to record verified users
 */
contract BiometricVerificationWorkflow {
    AfricanOriginProof public originProof;
    
    // Verification states
    enum VerificationStatus { PENDING, APPROVED, REJECTED }
    
    struct BiometricSubmission {
        bytes32 biometricHash;
        VerificationStatus status;
        address oracle;
        uint256 timestamp;
    }
    
    mapping(address => BiometricSubmission) public submissions;
    
    // Events
    event BiometricSubmitted(address indexed user, bytes32 bioHash);
    event BiometricVerified(address indexed user, address oracle);
    event BiometricRejected(address indexed user, address oracle);
    
    constructor(address _originProof) {
        originProof = AfricanOriginProof(_originProof);
    }
    
    /**
     * @notice User submits biometric data hash
     * @param bioHash Hash of the user's biometric data
     */
    function submitBiometric(bytes32 bioHash) external {
        require(bioHash != bytes32(0), "Invalid biometric hash");
        require(submissions[msg.sender].biometricHash == bytes32(0), "Already submitted");
        
        submissions[msg.sender] = BiometricSubmission({
            biometricHash: bioHash,
            status: VerificationStatus.PENDING,
            oracle: address(0),
            timestamp: block.timestamp
        });
        
        emit BiometricSubmitted(msg.sender, bioHash);
    }
    
    /**
     * @notice Oracle verifies biometric data (off-chain matching)
     * @param user Address of the user being verified
     * @param signature Oracle's signature of the biometric verification
     */
    function verifyBiometric(
        address user, 
        bytes calldata signature
    ) external {
        BiometricSubmission storage submission = submissions[user];
        require(submission.biometricHash != bytes32(0), "No submission found");
        require(submission.status == VerificationStatus.PENDING, "Already processed");
        
        // Verify oracle signature
        bytes32 messageHash = keccak256(abi.encodePacked(user, submission.biometricHash));
        address signer = recoverSigner(messageHash, signature);
        
        // Confirm oracle authorization
        require(originProof.isBiometricOracle(signer), "Unauthorized oracle");
        
        // Register verification
        bytes memory oracleSignature = signature; // Reuse oracle signature
        originProof.verifyBiometricOrigin(user, submission.biometricHash, oracleSignature);
        
        submission.status = VerificationStatus.APPROVED;
        submission.oracle = signer;
        
        emit BiometricVerified(user, signer);
    }
    
    /**
     * @notice Oracle rejects invalid submission
     * @param user Address of the user being rejected
     * @param reason Reason code for rejection
     */
    function rejectBiometric(address user, uint8 reason) external {
        require(originProof.isBiometricOracle(msg.sender), "Unauthorized");
        
        BiometricSubmission storage submission = submissions[user];
        require(submission.biometricHash != bytes32(0), "No submission found");
        require(submission.status == VerificationStatus.PENDING, "Already processed");
        
        submission.status = VerificationStatus.REJECTED;
        submission.oracle = msg.sender;
        
        emit BiometricRejected(user, msg.sender);
    }
    
    /**
     * @notice Get verification status for a user
     * @param user Address of the user
     * @return status Current verification status
     * @return timestamp Time of submission
     * @return oracle Address of verifying oracle (if any)
     */
    function getVerificationStatus(address user) 
        external 
        view 
        returns (VerificationStatus status, uint256 timestamp, address oracle) 
    {
        BiometricSubmission storage submission = submissions[user];
        return (submission.status, submission.timestamp, submission.oracle);
    }
    
    /**
     * @notice Check if a user's submission is still valid (not expired)
     * @param user Address of the user
     * @return isValid Whether the submission is still valid
     */
    function isValidSubmission(address user) external view returns (bool) {
        BiometricSubmission storage submission = submissions[user];
        if (submission.status != VerificationStatus.PENDING) {
            return false;
        }
        
        // Submissions valid for 7 days
        return (block.timestamp - submission.timestamp) <= 7 days;
    }
    
    // Signature recovery helper
    function recoverSigner(
        bytes32 messageHash, 
        bytes memory signature
    ) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        bytes32 ethSignedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        return ecrecover(ethSignedHash, v, r, s);
    }
    
    function splitSignature(bytes memory sig) internal pure returns (
        bytes32 r, 
        bytes32 s, 
        uint8 v
    ) {
        require(sig.length == 65, "Invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
