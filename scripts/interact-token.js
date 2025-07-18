const { ethers } = require("ethers");
require("dotenv").config();
const fs = require("fs");

// Contract ABI - Just the functions we need for basic interaction
const abi = [
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "function decimals() view returns (uint8)",
  "function totalSupply() view returns (uint256)",
  "function balanceOf(address) view returns (uint256)",
  "function transfer(address to, uint256 amount) returns (bool)"
];

async function main() {
  // Setup Provider and Wallet
  const provider = new ethers.JsonRpcProvider(process.env.CELO_ALFAJORES_RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  console.log(`Connected to Alfajores with address: ${wallet.address}`);
  
  // Load deployment info
  let deployInfo;
  try {
    deployInfo = JSON.parse(fs.readFileSync('./deployment-info-alfajores.json', 'utf8'));
    console.log(`Using contract at address: ${deployInfo.contractAddress}`);
    
    // Ensure contract address is properly formatted
    if (!deployInfo.contractAddress.startsWith('0x') || deployInfo.contractAddress.length !== 42) {
      console.error("Contract address appears malformed. Using hardcoded address.");
      deployInfo.contractAddress = "0x93F4c3B97aa4706e0a84f7667eB7f356F138dC60";
      console.log(`Using hardcoded contract address: ${deployInfo.contractAddress}`);
    }
  } catch (error) {
    console.error("Error loading deployment info:", error);
    console.log("Using hardcoded contract address instead.");
    deployInfo = {
      contractAddress: "0x93F4c3B97aa4706e0a84f7667eB7f356F138dC60"
    };
  }
  
  // Connect to the deployed contract
  const token = new ethers.Contract(deployInfo.contractAddress, abi, wallet);
  
  // Get basic token information
  console.log("\n=== TOKEN INFORMATION ===");
  const name = await token.name();
  const symbol = await token.symbol();
  const decimals = await token.decimals();
  const totalSupply = await token.totalSupply();
  
  console.log(`Name: ${name}`);
  console.log(`Symbol: ${symbol}`);
  console.log(`Decimals: ${decimals}`);
  console.log(`Total Supply: ${ethers.formatUnits(totalSupply, decimals)} ${symbol}`);
  
  // Check the deployer's balance
  const balance = await token.balanceOf(wallet.address);
  console.log(`\n=== BALANCE ===`);
  console.log(`Your balance: ${ethers.formatUnits(balance, decimals)} ${symbol}`);
  
  // Optional: Transfer some tokens if needed
  // Uncomment the following code to transfer tokens
  /*
  console.log("\n=== PERFORMING TRANSFER ===");
  const recipientAddress = "RECIPIENT_ADDRESS_HERE"; // Replace with actual recipient
  const transferAmount = ethers.parseUnits("10", decimals); // Transfer 10 tokens
  
  console.log(`Transferring ${ethers.formatUnits(transferAmount, decimals)} ${symbol} to ${recipientAddress}...`);
  const tx = await token.transfer(recipientAddress, transferAmount);
  console.log(`Transaction hash: ${tx.hash}`);
  
  console.log("Waiting for confirmation...");
  const receipt = await tx.wait();
  console.log(`Transfer confirmed in block ${receipt.blockNumber}`);
  
  // Check balance after transfer
  const newBalance = await token.balanceOf(wallet.address);
  console.log(`New balance: ${ethers.formatUnits(newBalance, decimals)} ${symbol}`);
  */
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
