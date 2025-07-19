require("dotenv").config();
const { ethers } = require("ethers");
const fs = require("fs");

async function deployToBSC() {
  console.log("🔥 Starting direct BSC deployment for FlameBornTokenV3...");
  
  // BSC Mainnet configuration
  const BSC_RPC_URL = process.env.BSC_MAINNET_RPC_URL || 'https://bsc-dataseed.binance.org/';
  const PRIVATE_KEY = process.env.PRIVATE_KEY;
  
  if (!PRIVATE_KEY) {
    console.error("❌ PRIVATE_KEY not found in environment variables");
    process.exit(1);
  }
  
  console.log("📡 Connecting to BSC Mainnet...");
  const provider = new ethers.providers.JsonRpcProvider(BSC_RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
  
  console.log(`🔑 Deployer address: ${wallet.address}`);
  
  // Check balance
  const balance = await wallet.getBalance();
  console.log(`💰 Balance: ${ethers.utils.formatEther(balance)} BNB`);
  
  if (balance.eq(0)) {
    console.error("❌ Insufficient BNB balance for deployment");
    process.exit(1);
  }
  
  // Load contract artifact
  let contractArtifact;
  try {
    const artifactPath = "./artifacts/contracts/FlameBornTokenV3.sol/FlameBornTokenV3.json";
    contractArtifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'));
  } catch (error) {
    console.error("❌ Contract artifact not found. Please run 'npx hardhat compile' first");
    process.exit(1);
  }
  
  console.log("🏭 Creating contract factory...");
  const contractFactory = new ethers.ContractFactory(
    contractArtifact.abi,
    contractArtifact.bytecode,
    wallet
  );
  
  const initialSupply = 1000000;
  console.log(`🚀 Deploying FlameBornTokenV3 with initial supply: ${initialSupply}...`);
  
  try {
    const contract = await contractFactory.deploy(initialSupply);
    console.log("📤 Transaction sent, waiting for confirmation...");
    
    await contract.deployed();
    
    console.log(`✅ Contract deployed successfully!`);
    console.log(`📍 Contract address: ${contract.address}`);
    console.log(`🔗 BSCScan: https://bscscan.com/address/${contract.address}`);
    
    // Save deployment info
    const deploymentInfo = {
      network: "bsc",
      contractAddress: contract.address,
      deployerAddress: wallet.address,
      deploymentTime: new Date().toISOString(),
      transactionHash: contract.deployTransaction.hash,
      initialSupply: initialSupply
    };
    
    fs.writeFileSync('deployment-info-bsc.json', JSON.stringify(deploymentInfo, null, 2));
    console.log("💾 Deployment info saved to deployment-info-bsc.json");
    
    console.log(`\n🔍 To verify the contract, run:`);
    console.log(`npx hardhat verify --network bsc ${contract.address} ${initialSupply}`);
    
    return contract.address;
    
  } catch (error) {
    console.error("❌ Deployment failed:", error.message);
    process.exit(1);
  }
}

deployToBSC()
  .then((address) => {
    console.log(`\n🎉 Deployment completed successfully!`);
    console.log(`Contract Address: ${address}`);
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Deployment script failed:", error);
    process.exit(1);
  });
