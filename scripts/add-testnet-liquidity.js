const hre = require("hardhat");
const IUniswapV2Router02 = require("@uniswap/v2-periphery/build/IUniswapV2Router02.json");

async function main() {
  const tokenAddress = "0x93F4c3B97aa4706e0a84f7667eB7f356F138dC60"; // Replace with your token address
  const cUSDAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1"; // cUSD address on Alfajores

  const [deployer] = await hre.ethers.getSigners();
  console.log("Using account:", deployer.address);

  // Get the token contract
  const token = await hre.ethers.getContractAt("FlameBornToken", tokenAddress);

  // Amounts to add to liquidity
  const tokenAmount = hre.ethers.utils.parseUnits("1000", 18); // 1000 FLB
  const cUSDAmount = hre.ethers.utils.parseUnits("100", 18); // 100 cUSD

  // Approve the router to spend the tokens
  console.log("Approving router to spend FLB...");
  await token.approve("0xE3D8bd6Aed4F159bc8000a9cD47CffDb4F75d54a", tokenAmount); // Ubeswap router address

  // Get the router instance
  const router = await hre.ethers.getContractAt(
    IUniswapV2Router02.abi,
    "0xE3D8bd6Aed4F159bc8000a9cD47CffDb4F75d54a" // Ubeswap router
  );

  // Add liquidity
  console.log("Adding liquidity...");
  await router.addLiquidity(
    tokenAddress,
    cUSDAddress,
    tokenAmount,
    cUSDAmount,
    0, // slippage tolerance (min)
    0, // slippage tolerance (min)
    deployer.address,
    Math.floor(Date.now() / 1000) + 60 * 20, // 20 minutes from now
    { value: 0 }
  );

  console.log("Liquidity added!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
