const { ethers } = require("ethers");
require("dotenv").config();

// Hardcoded contract address from our successful deployment
const CONTRACT_ADDRESS = "0x93F4c3B97aa4706e0a84f7667eB7f356F138dC60";

// Minimal ABI for basic token interactions
const abi = [
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "function decimals() view returns (uint8)",
  "function totalSupply() view returns (uint256)",
  "function balanceOf(address) view returns (uint256)"
];

async function main() {
  // Setup Provider and Wallet
  console.log("Connecting to Celo Alfajores...");
  const provider = new ethers.JsonRpcProvider(process.env.CELO_ALFAJORES_RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  console.log(`Using wallet address: ${wallet.address}`);
  console.log(`Using contract address: ${CONTRACT_ADDRESS}`);
  
  // Connect to the contract
  const token = new ethers.Contract(CONTRACT_ADDRESS, abi, provider);
  
  try {
    // Get token info
    console.log("\n=== TOKEN INFORMATION ===");
    const name = await token.name();
    console.log(`Name: ${name}`);
    
    const symbol = await token.symbol();
    console.log(`Symbol: ${symbol}`);
    
    const decimals = await token.decimals();
    console.log(`Decimals: ${decimals}`);
    
    const totalSupply = await token.totalSupply();
    console.log(`Total Supply: ${ethers.formatUnits(totalSupply, decimals)} ${symbol}`);
    
    // Get wallet balance
    const balance = await token.balanceOf(wallet.address);
    console.log(`\n=== WALLET BALANCE ===`);
    console.log(`Your balance: ${ethers.formatUnits(balance, decimals)} ${symbol}`);
    
    console.log("\nContract interaction successful!");
  } catch (error) {
    console.error("Error interacting with contract:", error.message);
    if (error.message.includes("call revert exception")) {
      console.log("\nThis might indicate the contract was deployed but its functions don't match the expected ABI.");
      console.log("Check if the contract has the standard ERC20 functions implemented.");
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error("Fatal error:", error);
    process.exit(1);
  });
