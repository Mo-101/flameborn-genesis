const hre = require("hardhat");

async function main() {
  const contractAddress = "0x93F4c3B97aa4706e0a84f7667eB7f356F138dC60";
  const [deployer] = await hre.ethers.getSigners();
  console.log("Using account:", deployer.address);
  const FLB = await ethers.getContractAt("FlameBornToken", contractAddress, deployer);

  // Check deployer FLB token balance
  const flbBalance = await FLB.balanceOf(deployer.address);
  console.log(`Deployer FLB balance: ${ethers.utils.formatUnits(flbBalance, 18)} FLB`);
  // Check deployer CELO balance
  const celoBalance = await deployer.getBalance();
  console.log(`Deployer CELO balance: ${ethers.utils.formatEther(celoBalance)} CELO`);

  // --- Airdrop Configuration ---
  const airdropAddresses = [
    "0x96555d34de3ddc1ca99f5f4ba56918b5f50c7df8",
    "0x9cbd615eee98cbcbb76cbe976107d30543b5f72b",
    "0x04afaae68ecd88dcff32c4d7ed2ed4b4d01dc3bb",
  ];

  const amountToSend = ethers.utils.parseUnits("100", 18); // Amount of tokens to send to each address (e.g., 100 tokens)
  const gasPrice = ethers.utils.parseUnits("30", "gwei"); // Set gas price to 30 gwei

  console.log(`Airdropping ${ethers.utils.formatUnits(amountToSend, 18)} FLB to ${airdropAddresses.length} addresses...`);

  // Check deployer FLB and CELO balance before airdrop
  console.log(`Deployer FLB balance before airdrop: ${ethers.utils.formatUnits(flbBalance, 18)} FLB`);
  console.log(`Deployer CELO balance before airdrop: ${ethers.utils.formatEther(celoBalance)} CELO`);

  for (const recipient of airdropAddresses) {
    try {
      const tx = await FLB.transfer(recipient, amountToSend, { gasPrice, gasLimit: 200000 });
      await tx.wait();
      console.log(`✅ Sent ${ethers.utils.formatUnits(amountToSend, 18)} FLB to ${recipient}`);
    } catch (error) {
      console.error(`Failed to send tokens to ${recipient}:`, error.message);
    }
  }

  console.log("Airdrop of FLB Completed!!.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
