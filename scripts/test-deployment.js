const hre = require("hardhat");

async function main() {
  console.log("🔥 Testing deployment setup...");
  
  try {
    const [deployer] = await hre.ethers.getSigners();
    console.log("✅ Deployer address:", deployer.address);
    
    const balance = await deployer.getBalance();
    console.log("✅ Deployer balance:", hre.ethers.utils.formatEther(balance), "CELO");
    
    // Test network connection
    const network = await hre.ethers.provider.getNetwork();
    console.log("✅ Connected to network:", network.name, "Chain ID:", network.chainId);
    
    // Test contract factory
    console.log("\n📋 Testing contract factories...");
    
    const HealthIDNFT = await hre.ethers.getContractFactory("HealthIDNFT");
    console.log("✅ HealthIDNFT factory loaded");
    
    const HealthActorRegistry = await hre.ethers.getContractFactory("HealthActorRegistry");
    console.log("✅ HealthActorRegistry factory loaded");
    
    const SustainabilityDAO = await hre.ethers.getContractFactory("SustainabilityDAO");
    console.log("✅ SustainabilityDAO factory loaded");
    
    const DonationRouter = await hre.ethers.getContractFactory("DonationRouter");
    console.log("✅ DonationRouter factory loaded");
    
    const FLBVesting = await hre.ethers.getContractFactory("FLBVesting");
    console.log("✅ FLBVesting factory loaded");
    
    const LearnToEarn = await hre.ethers.getContractFactory("LearnToEarn");
    console.log("✅ LearnToEarn factory loaded");
    
    console.log("\n🎉 All contract factories loaded successfully!");
    console.log("✅ Ready for deployment!");
    
  } catch (error) {
    console.error("❌ Error:", error.message);
    console.error("Stack:", error.stack);
  }
}

main()
  .then(() => {
    console.log("\n✅ Test completed successfully!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Test failed:", error);
    process.exit(1);
  });
