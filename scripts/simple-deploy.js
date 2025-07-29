// Simple deployment script with clear console output
require('dotenv').config();
const { ethers } = require('ethers');
const fs = require('fs');

// Load contract ABI and bytecode
const contractJson = require('../artifacts/contracts/FlameBornToken.sol/FlameBornToken.json');

async function main() {
  console.log('=====================================');
  console.log('FLAMEBORN TOKEN DEPLOYMENT');
  console.log('=====================================');
  
  // Network setup - Alfajores testnet
  const network = process.argv[2] || 'alfajores';
  console.log(`Network: ${network}`);
  
  // Get configuration from .env
  const privateKey = process.env.PRIVATE_KEY;
  const rpcUrl = network === 'alfajores' 
    ? process.env.CELO_ALFAJORES_RPC_URL 
    : process.env.CELO_MAINNET_RPC_URL;

  console.log(`RPC URL: ${rpcUrl}`);
  
  // Create provider and wallet
  const provider = new ethers.JsonRpcProvider(rpcUrl);
  const wallet = new ethers.Wallet(privateKey, provider);
  console.log(`Deployer address: ${wallet.address}`);
  
  // Check wallet balance
  const balance = await provider.getBalance(wallet.address);
  console.log(`Account balance: ${ethers.formatEther(balance)} CELO`);
  
  // Create contract factory
  const initialSupply = 1000000;
  const factory = new ethers.ContractFactory(
    contractJson.abi,
    contractJson.bytecode,
    wallet
  );
  
  console.log(`Deploying FlameBornToken with initial supply: ${initialSupply}...`);
  
  // Deploy contract
  try {
    const contract = await factory.deploy(initialSupply);
    console.log(`Transaction sent! Hash: ${contract.deploymentTransaction().hash}`);
    
    console.log('Waiting for confirmation...');
    await contract.deploymentTransaction().wait(1);
    
    const contractAddress = await contract.getAddress();
    console.log(`\n✅ SUCCESS! Contract deployed at: ${contractAddress}`);
    
    // Save deployment info
    const deployInfo = {
      network,
      address: contractAddress,
      deployer: wallet.address,
      initialSupply,
      deployedAt: new Date().toISOString()
    };
    
    fs.writeFileSync(
      `deployment-${network}.json`,
      JSON.stringify(deployInfo, null, 2)
    );
    
    console.log(`\nDeployment info saved to deployment-${network}.json`);
    console.log(`\nVerification command: npx hardhat verify --network ${network} ${contractAddress} ${initialSupply}`);
  } catch (error) {
    console.error('\n❌ DEPLOYMENT FAILED:');
    console.error(error.message);
    
    if (error.message.includes('insufficient funds')) {
      console.error('\nThe test account has insufficient CELO. Please fund it before deployment.');
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
