const { ethers } = require('ethers');

// Generate a random wallet
const wallet = ethers.Wallet.createRandom();

console.log("Address:", wallet.address);
console.log("Private Key:", wallet.privateKey);
console.log("\nSave this private key in your .env file as PRIVATE_KEY=", wallet.privateKey);
console.log("\nIMPORTANT: This is a development wallet only. For mainnet deployment, use a secure wallet!");
