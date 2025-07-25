const hre = require("hardhat");

async function main() {
  console.log("🔥 Starting step-by-step deployment...");
  
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deployer:", deployer.address);
  
  const balance = await deployer.getBalance();
  console.log("Balance:", hre.ethers.utils.formatEther(balance), "CELO");
  
  // Existing FlameBorn Token
  const tokenAddress = "0x93F4c3B97aa4706e0a84f7667eB7f356F138dC60";
  console.log("Using FlameBorn Token at:", tokenAddress);
  
  try {
    // Deploy HealthIDNFT
    console.log("\n1. Deploying HealthIDNFT...");
    const HealthIDNFT = await hre.ethers.getContractFactory("HealthIDNFT");
    const healthIDNFT = await HealthIDNFT.deploy();
    await healthIDNFT.deployed();
    console.log("✅ HealthIDNFT deployed:", healthIDNFT.address);
    
    // Deploy HealthActorRegistry
    console.log("\n2. Deploying HealthActorRegistry...");
    const HealthActorRegistry = await hre.ethers.getContractFactory("HealthActorRegistry");
    const healthActorRegistry = await HealthActorRegistry.deploy(
      deployer.address,
      tokenAddress,
      healthIDNFT.address
    );
    await healthActorRegistry.deployed();
    console.log("✅ HealthActorRegistry deployed:", healthActorRegistry.address);
    
    console.log("\n🎉 Deployment successful!");
    console.log("HealthIDNFT:", healthIDNFT.address);
    console.log("HealthActorRegistry:", healthActorRegistry.address);
    
  } catch (error) {
    console.error("❌ Error:", error.message);
  }
}

main();
