const { ethers } = require("ethers");
require("dotenv").config();
const fs = require("fs");

async function main() {
  // 1. Setup Provider and Wallet
  const provider = new ethers.JsonRpcProvider(process.env.CELO_ALFAJORES_RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  console.log(`Deploying contracts with the account: ${wallet.address}`);

  // 2. Load Contract Artifact
  const artifactPath = 'contracts/artifacts/contracts/FlameBornToken.sol/FlameBornTokenV3.json';
  if (!fs.existsSync(artifactPath)) {
      console.error(`Artifact not found at path: ${artifactPath}`);
      console.error('Please compile your contracts first by running "npx hardhat compile"');
      process.exit(1);
  }
  const contractArtifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'));
  const abi = contractArtifact.abi;
  const bytecode = contractArtifact.bytecode;

  // 3. Deploy Contract
  const ContractFactory = new ethers.ContractFactory(abi, bytecode, wallet);
  console.log('Deploying FlameBornTokenV3...');
  
  // The initial supply for the constructor
  const initialSupply = ethers.parseUnits("1000000", 18); // Example: 1 million tokens

  const contract = await ContractFactory.deploy(initialSupply);
  await contract.waitForDeployment();

  const contractAddress = await contract.getAddress();
  console.log(`FlameBornTokenV3 deployed to: ${contractAddress}`);

  // 4. Save deployment info
  const deploymentInfo = {
    network: 'alfajores',
    contractAddress: contractAddress,
    deployerAddress: wallet.address,
    deploymentDate: new Date().toISOString(),
  };

  fs.writeFileSync(
    `deployment-info-alfajores.json`,
    JSON.stringify(deploymentInfo, null, 2)
  );

  console.log('Deployment information saved to deployment-info-alfajores.json');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
