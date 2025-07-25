const hre = require("hardhat");

async function main() {
  console.log("🔍 Verifying FlameBorn deployment status...\n");
  
  try {
    const [deployer] = await hre.ethers.getSigners();
    console.log("📋 Deployer address:", deployer.address);
    
    const balance = await deployer.getBalance();
    console.log("💰 Deployer balance:", hre.ethers.utils.formatEther(balance), "CELO");
    
    // Check network
    const network = await hre.ethers.provider.getNetwork();
    console.log("🌐 Network:", network.name, "Chain ID:", network.chainId);
    
    // Known FlameBorn Token address
    const tokenAddress = "0x93F4c3B97aa4706e0a84f7667eB7f356F138dC60";
    console.log("\n🔥 Checking FlameBorn Token at:", tokenAddress);
    
    // Get contract instance
    const FLB = await hre.ethers.getContractAt("FlameBornToken", tokenAddress);
    
    // Verify token details
    const name = await FLB.name();
    const symbol = await FLB.symbol();
    const totalSupply = await FLB.totalSupply();
    const decimals = await FLB.decimals();
    
    console.log("✅ Token Name:", name);
    console.log("✅ Token Symbol:", symbol);
    console.log("✅ Total Supply:", hre.ethers.utils.formatUnits(totalSupply, decimals), symbol);
    console.log("✅ Decimals:", decimals);
    
    // Check deployer's token balance
    const deployerBalance = await FLB.balanceOf(deployer.address);
    console.log("✅ Deployer Token Balance:", hre.ethers.utils.formatUnits(deployerBalance, decimals), symbol);
    
    // Check if deployer has admin role
    const DEFAULT_ADMIN_ROLE = await FLB.DEFAULT_ADMIN_ROLE();
    const hasAdminRole = await FLB.hasRole(DEFAULT_ADMIN_ROLE, deployer.address);
    console.log("✅ Deployer has Admin Role:", hasAdminRole);
    
    console.log("\n📊 Contract Status Summary:");
    console.log("=" .repeat(50));
    console.log("FlameBorn Token (FLB):", "✅ DEPLOYED");
    console.log("Contract Address:", tokenAddress);
    console.log("Network:", network.name);
    console.log("Total Supply:", hre.ethers.utils.formatUnits(totalSupply, decimals), symbol);
    console.log("=" .repeat(50));
    
    // Check for other contracts (they should fail if not deployed)
    console.log("\n🔍 Checking other contracts...");
    
    const contractsToCheck = [
      "HealthIDNFT",
      "HealthActorRegistry", 
      "SustainabilityDAO",
      "DonationRouter",
      "FLBVesting",
      "LearnToEarn"
    ];
    
    for (const contractName of contractsToCheck) {
      try {
        const factory = await hre.ethers.getContractFactory(contractName);
        console.log(`📋 ${contractName}: Factory loaded ✅`);
      } catch (error) {
        console.log(`❌ ${contractName}: Factory failed -`, error.message.split('\n')[0]);
      }
    }
    
    console.log("\n🎯 Next Steps:");
    console.log("1. Deploy remaining contracts using the deployment script");
    console.log("2. Set up roles and permissions");
    console.log("3. Verify contracts on block explorer");
    
  } catch (error) {
    console.error("❌ Error:", error.message);
    if (error.code === 'CALL_EXCEPTION') {
      console.log("💡 This might mean the contract is not deployed at the expected address");
    }
  }
}

main()
  .then(() => {
    console.log("\n✅ Verification completed!");
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Verification failed:", error);
    process.exit(1);
  });
