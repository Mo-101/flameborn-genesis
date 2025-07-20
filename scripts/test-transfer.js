const hre = require("hardhat");

async function main() {
  const tokenAddress = "0x93F4c3B97aa4706e0a84f7667eB7f356F138dC60";
  const treasuryAddress = "0x93F4c3B97aa4706e0a84f7667eB7f356F138dC60";
  const deadAddress = "0x000000000000000000000000000000000000dEaD";

  const [deployer] = await hre.ethers.getSigners();
  console.log("Using account:", deployer.address);

  // Get the contract instance
  const token = await hre.ethers.getContractAt("contracts/FlameBornToken.sol:FlameBornToken", tokenAddress);

  // Transfer 100 tokens to dead address (should trigger 2% tax)
  const amount = hre.ethers.utils.parseUnits("100", 18); // 100 tokens
  console.log(`Transferring ${hre.ethers.utils.formatUnits(amount, 18)} tokens to dead address...`);
  await token.transfer(deadAddress, amount);

  // Check treasury balance after transfer
  const treasuryBalance = await token.balanceOf(treasuryAddress);
  console.log(
    "Treasury balance after transfer:",
    hre.ethers.utils.formatUnits(treasuryBalance, 18),
    "FLB"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
