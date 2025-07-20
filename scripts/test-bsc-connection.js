const hre = require("hardhat");

async function testBSCConnection() {
  console.log("🔍 Testing BSC connection...");
  console.log(`Network: ${hre.network.name}`);
  console.log(`Chain ID: ${hre.network.config.chainId}`);
  
  try {
    const [deployer] = await hre.ethers.getSigners();
    console.log(`Deployer address: ${deployer.address}`);
    
    const balance = await deployer.getBalance();
    console.log(`Balance: ${hre.ethers.utils.formatEther(balance)} BNB`);
    
    const provider = hre.ethers.provider;
    const network = await provider.getNetwork();
    console.log(`Connected to network: ${network.name} (Chain ID: ${network.chainId})`);
    
  } catch (error) {
    console.error("❌ Connection test failed:", error.message);
  }
}

testBSCConnection()
  .then(() => {
    console.log("✅ Connection test completed");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Test failed:", error);
    process.exit(1);
  });
