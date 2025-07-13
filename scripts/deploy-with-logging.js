// Deploy with extra logging
const hre = require("hardhat");
const fs = require("fs");

async function main() {
  try {
    // Record start time for performance tracking
    const startTime = new Date();
    console.log(`\n=============================================`);
    console.log(`DEPLOYMENT STARTED at ${startTime.toISOString()}`);
    console.log(`Network: ${hre.network.name}`);
    console.log(`=============================================\n`);

    console.log(`[1/5] Starting deployment to ${hre.network.name}...`);

    console.log("[2/5] Getting deployer account...");
    const [deployer] = await hre.ethers.getSigners();
    console.log(`   > Deployer address: ${deployer.address}`);
    console.log(`   > Deployer balance: ${await deployer.provider.getBalance(deployer.address)}`);

    console.log("[3/5] Getting contract factory for FlameBornTokenV3...");
    const FlameBornToken = await hre.ethers.getContractFactory("FlameBornTokenV3");

    const initialSupply = 1000000;
    console.log(`[4/5] Deploying contract with initial supply of ${initialSupply} tokens...`);
    const deployTx = await FlameBornToken.deploy(initialSupply);
    console.log("   > Transaction sent, waiting for deployment...");
    console.log(`   > Transaction hash: ${deployTx.deploymentTransaction().hash}`);

    await deployTx.waitForDeployment();
    const tokenAddress = await deployTx.getAddress();
    
    // Get transaction receipt for more details
    const receipt = await deployTx.deploymentTransaction().wait();
    
    console.log("[5/5] Contract deployed successfully.");
    console.log(`\n=============================================`);
    console.log(`🔥 FlameBornToken deployed to ${tokenAddress} on ${hre.network.name}`);
    console.log(`   > Gas used: ${receipt.gasUsed.toString()}`);
    console.log(`   > Block: ${receipt.blockNumber}`);
    console.log(`   > Deployment time: ${(new Date() - startTime) / 1000} seconds`);
    console.log(`=============================================\n`);

    console.log(`\n📋 Contract verification command:\nnpx hardhat verify --network ${hre.network.name} ${tokenAddress} ${initialSupply}\n`);

    // Save the contract address for other scripts
    const deploymentInfo = {
      network: hre.network.name,
      tokenAddress: tokenAddress,
      deployer: deployer.address,
      blockNumber: receipt.blockNumber,
      initialSupply: initialSupply,
      timestamp: new Date().toISOString()
    };

    const deploymentDir = "./deployments";
    if (!fs.existsSync(deploymentDir)) {
      fs.mkdirSync(deploymentDir);
    }

    fs.writeFileSync(
      `${deploymentDir}/deployment-${hre.network.name}.json`,
      JSON.stringify(deploymentInfo, null, 2)
    );

    console.log(`Deployment information saved to ${deploymentDir}/deployment-${hre.network.name}.json`);
    
    return {
      success: true,
      tokenAddress,
      network: hre.network.name
    };
  } catch (error) {
    console.error("\n❌ DEPLOYMENT FAILED");
    console.error("=============================================");
    console.error(error);
    console.error("=============================================\n");
    return {
      success: false,
      error: error.message
    };
  }
}

// Handle errors in deployment
if (require.main === module) {
  main()
    .then((result) => {
      if (result.success) {
        console.log(`\n✅ Deployment completed successfully to ${result.network}`);
      } else {
        console.log(`\n❌ Deployment failed: ${result.error}`);
      }
      process.exit(result.success ? 0 : 1);
    })
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = main;
