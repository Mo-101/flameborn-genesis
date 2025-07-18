// Standalone deployer balance checker for Celo Alfajores using ethers.js
require('dotenv').config();
const { ethers } = require('ethers');

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CELO_ALFAJORES_RPC_URL = process.env.CELO_ALFAJORES_RPC_URL || 'https://alfajores-forno.celo-testnet.org';

async function main() {
  if (!PRIVATE_KEY) {
    console.error('❌ PRIVATE_KEY not set in .env');
    process.exit(1);
  }
  const provider = new ethers.JsonRpcProvider(CELO_ALFAJORES_RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
  const address = wallet.address;
  const balance = await provider.getBalance(address);
  console.log(`\nNetwork: Celo Alfajores\nDeployer Address: ${address}\nBalance: ${ethers.formatEther(balance)} CELO\n`);
}

main().catch((e) => {
  console.error('Error checking balance:', e);
  process.exit(1);
});
