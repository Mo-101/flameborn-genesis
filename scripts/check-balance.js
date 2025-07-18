async function main() {
  const hre = require("hardhat");
  const [deployer] = await hre.ethers.getSigners();
  const balance = await hre.ethers.provider.getBalance(deployer.address);

  console.log(`\nNetwork: ${hre.network.name}\nDeployer Address: ${deployer.address}\nBalance: ${hre.ethers.formatEther(balance)} CELO\n`);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error("Error checking balance:", error);
    process.exit(1);
  });
