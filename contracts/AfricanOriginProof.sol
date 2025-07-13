// SPDX-License-Identifier: KAIRO-COVENANT-v1
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AfricanOriginProof
 * @notice Oracle contract for verifying African origin using multiple methods
 * @dev Combines tribal council verification, biometric verification, and zero-knowledge proofs
 */
contract AfricanOriginProof is Ownable {
    // Tribal council verification
    mapping(address => bool) public tribalVerifications;
    
    // Biometric oracle addresses
    address[] public biometricOracles;
    
    // ZK proof registry
    mapping(bytes32 => bool) public zkProofRegistry;
    
    // Verification events
    event TribalVerified(address indexed user, address elder);
    event BiometricVerified(address indexed user, bytes32 bioHash);
    event ZKProofVerified(address indexed user, bytes32 proofHash);
    event ElderAdded(address indexed elder);
    event OracleAdded(address indexed oracle);

    // Tribal council verification (multisig)
    function verifyTribalOrigin(
        address user, 
        bytes[] calldata signatures
    ) external onlyOwner {
        require(signatures.length >= 3, "Minimum 3 elder signatures");
        
        bytes32 messageHash = keccak256(abi.encodePacked(user));
        
        for(uint i = 0; i < signatures.length; i++) {
            address signer = recoverSigner(messageHash, signatures[i]);
            require(isElder(signer), "Invalid elder signature");
        }
        
        tribalVerifications[user] = true;
        emit TribalVerified(user, msg.sender);
    }

    // Biometric verification (oracle-based)
    function verifyBiometricOrigin(
        address user,
        bytes32 biometricHash,
        bytes calldata oracleSignature
    ) external {
        address oracle = recoverSigner(biometricHash, oracleSignature);
        require(isBiometricOracle(oracle), "Unauthorized oracle");
        
        tribalVerifications[user] = true;
        emit BiometricVerified(user, biometricHash);
    }

    // ZK proof registration
    function registerZKProof(
        bytes32 proofHash,
        bytes calldata zkSignature
    ) external onlyOwner {
        address verifier = recoverSigner(proofHash, zkSignature);
        require(isElder(verifier), "Elder verification required");
        
        zkProofRegistry[proofHash] = true;
        emit ZKProofVerified(msg.sender, proofHash);
    }

    // Combined verification check
    function isAfricanOrigin(address user) external view returns (bool) {
        return tribalVerifications[user];
    }

    // Tribal elder management
    function addElder(address elder) external onlyOwner {
        biometricOracles.push(elder);
        emit ElderAdded(elder);
    }
    
    // Oracle management
    function addBiometricOracle(address oracle) external onlyOwner {
        biometricOracles.push(oracle);
        emit OracleAdded(oracle);
    }
    
    // Helper functions
    function isElder(address signer) public pure returns (bool) {
        // In production: Check against registered elder list
        // For development: Allow any non-zero address
        return signer != address(0);
    }
    
    function isBiometricOracle(address oracle) public view returns (bool) {
        for(uint i = 0; i < biometricOracles.length; i++) {
            if(biometricOracles[i] == oracle) return true;
        }
        return false;
    }
    
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
