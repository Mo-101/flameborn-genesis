const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const balance = await hre.ethers.provider.getBalance(deployer.address);

  console.log(`
Network: ${hre.network.name}
Deployer Address: ${deployer.address}
Balance: ${hre.ethers.formatEther(balance)} CELO
  `);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error("Error checking balance:", error);
    process.exit(1);
  });
