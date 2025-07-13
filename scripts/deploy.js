const hre = require("hardhat");
const fs = require("fs");

async function main() {
  console.log(`
[1/5] Starting deployment to ${hre.network.name}...`);

  console.log("[2/5] Getting deployer account...");
  const [deployer] = await hre.ethers.getSigners();
  console.log(`   > Deployer address: ${deployer.address}`);

  console.log("[3/5] Getting contract factory for FlameBornTokenV3...");
  const FlameBornToken = await hre.ethers.getContractFactory("FlameBornTokenV3");

  const initialSupply = 1000000;
  console.log(`[4/5] Deploying contract with initial supply of ${initialSupply} tokens...`);
  const flameBornToken = await FlameBornToken.deploy(initialSupply);
  console.log("   > Transaction sent, waiting for deployment...");

  await flameBornToken.waitForDeployment();
  const tokenAddress = await flameBornToken.getAddress();
  console.log("[5/5] Contract deployed successfully.");

  console.log(`\n🔥 FlameBornToken deployed to ${tokenAddress} on ${hre.network.name}\n`);

  console.log(`\n📋 Contract verification command:\nnpx hardhat verify --network ${hre.network.name} ${tokenAddress} ${initialSupply}\n`);

  // Save the contract address for other scripts
  const deploymentInfo = {
    network: hre.network.name,
    contractAddress: tokenAddress,
    deployerAddress: deployer.address
  };
  fs.writeFileSync(`deployment-info-${hre.network.name}.json`, JSON.stringify(deploymentInfo, null, 2));
  console.log(`\n✅ Deployment info saved to deployment-info-${hre.network.name}.json`);

  // Log next steps for validators
  console.log(`\n🌍 Next steps:\n1. Add initial validators with: await flameBornToken.grantRole(await flameBornToken.VALIDATOR_ROLE(), "VALIDATOR_ADDRESS")\n2. Set up tribal council with: await flameBornToken.grantRole(await flameBornToken.TRIBAL_COUNCIL_ROLE(), "TRIBAL_COUNCIL_ADDRESS")\n3. Verify contract on ${hre.network.name === "alfajores" ? "Alfajores Explorer" : "CeloScan"}\n`);
}

// Handle errors in deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n❌ Deployment failed:", error);
    process.exit(1);
  });