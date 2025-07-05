// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Using a recent pragma for modern features

// We need to import the ECDSA library from OpenZeppelin to perform signature verification.
// Make sure you have OpenZeppelin Contracts v5+ installed: npm install @openzeppelin/contracts@^5.0.0
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title SignatureVerifier
 * @dev A simple contract to demonstrate and verify ECDSA signatures on-chain.
 * It uses OpenZeppelin's ECDSA library for robust verification.
 */
contract SignatureVerifier {
    // We'll use the ECDSA library directly.
    using ECDSA for bytes32; // This allows us to call .recover() directly on a bytes32 hash.

    /**
     * @dev Emits the recovered signer address. Useful for logging and debugging.
     * @param _hash The message hash that was signed.
     * @param _signature The ECDSA signature.
     * @param _signer The address recovered from the signature.
     */
    event SignatureVerified(
        bytes32 indexed _hash,
        bytes32 indexed _signature,
        address indexed _signer
    );

    /**
     * @dev Verifies an ECDSA signature given a message hash and the signature itself.
     * @param _hash The message hash (bytes32) that was signed.
     * @param _signature The raw ECDSA signature (bytes).
     * @return The address that produced the signature.
     * Returns address(0) if the signature is invalid.
     */
    function verifySignature(
    bytes32 _hash,
    bytes memory _signature
    ) public pure returns (address) {

        // The .recover() function from OpenZeppelin's ECDSA library takes a
        // signed hash and a signature, and returns the signer's address.
        // It handles the message prefixing implicitly if the hash was signed
        // using web3.eth.sign or ethers.js signMessage.
        address signer = _hash.recover(_signature);

        emit SignatureVerified(_hash, _signature, signer);

        return signer;
    }

    /**
     * @dev A helper function to verify a signature that was created from a string message,
     * which needs to be hashed and prefixed according to EIP-191 before verification.
     * @param _message The original string message that was signed.
     * @param _signature The raw ECDSA signature (bytes).
     * @return The address that produced the signature.
     * Returns address(0) if the signature is invalid.
     */
    function verifyMessageSignature(
        string memory _message,
        bytes memory _signature

    ) 
    