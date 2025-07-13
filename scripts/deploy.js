const hre = require("hardhat");

async function main() {
  console.log("Deploying FlameBornToken to", network.name);
  
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);
  
  // Deploy the FlameBornToken contract
  const FlameBornToken = await hre.ethers.getContractFactory("FlameBornTokenV3");
  console.log("Initiating contract deployment...");
  
  // Initial supply: 1 million tokens
  const initialSupply = 1000000;
  const flameBornToken = await FlameBornToken.deploy(initialSupply);
  
  await flameBornToken.waitForDeployment();
  
  const tokenAddress = await flameBornToken.getAddress();
  console.log(`\n🔥 FlameBornToken deployed to ${tokenAddress} on ${network.name}\n`);
  console.log(`\n📋 Contract verification command:\nnpx hardhat verify --network ${network.name} ${tokenAddress} ${initialSupply}\n`);
  
  // Log next steps for validators
  console.log(`\n🌍 Next steps:\n1. Add initial validators with: await flameBornToken.grantRole(await flameBornToken.VALIDATOR_ROLE(), "VALIDATOR_ADDRESS")\n2. Set up tribal council with: await flameBornToken.grantRole(await flameBornToken.TRIBAL_COUNCIL_ROLE(), "TRIBAL_COUNCIL_ADDRESS")\n3. Verify contract on ${network.name === "alfajores" ? "Alfajores Explorer" : "CeloScan"}\n`);
}

// Handle errors in deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n❌ Deployment failed:", error);
    process.exit(1);
  });