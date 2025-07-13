const hre = require("hardhat");

async function main() {
  // Get contract address from command line
  const contractAddress = process.argv[2];
  if (!contractAddress) {
    console.error("❌ Please provide contract address: node scripts/verify.js <CONTRACT_ADDRESS>");
    process.exit(1);
  }

  // Initial supply: 1 million tokens (must match deployment)
  const initialSupply = 1000000;
  
  console.log(`🔍 Verifying FlameBornToken at ${contractAddress} on ${network.name}...`);
  
  try {
    await hre.run("verify:verify", {
      address: contractAddress,
      constructorArguments: [initialSupply],
    });
    console.log(`✅ Contract verified successfully on ${network.name === "alfajores" ? "Alfajores Explorer" : "CeloScan"}`);
  } catch (error) {
    console.error("❌ Verification failed:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
