const hre = require("hardhat");

async function main() {
  const SignatureVerifier = await hre.ethers.getContractFactory("SignatureVerifier");
  const signatureVerifier = await SignatureVerifier.deploy();

  await signatureVerifier.waitForDeployment();

  console.log(
    `SignatureVerifier deployed to ${signatureVerifier.target}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});