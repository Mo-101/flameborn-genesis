require("dotenv").config();
const { ethers } = require("ethers");

async function testBSCNetwork() {
  console.log("🔍 Testing BSC network connectivity...");
  
  // Try different BSC RPC endpoints
  const rpcEndpoints = [
    'https://bsc-dataseed.binance.org/',
    'https://bsc-dataseed1.binance.org/',
    'https://bsc-dataseed2.binance.org/',
    'https://bsc-dataseed3.binance.org/',
    'https://bsc-dataseed4.binance.org/'
  ];
  
  for (let i = 0; i < rpcEndpoints.length; i++) {
    const rpcUrl = rpcEndpoints[i];
    console.log(`\n📡 Testing RPC ${i + 1}: ${rpcUrl}`);
    
    try {
      const provider = new ethers.providers.JsonRpcProvider(rpcUrl);
      
      // Test basic connectivity
      const network = await provider.getNetwork();
      console.log(`✅ Connected to ${network.name} (Chain ID: ${network.chainId})`);
      
      // Test wallet connection
      const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
      console.log(`🔑 Wallet address: ${wallet.address}`);
      
      // Test balance check
      const balance = await wallet.getBalance();
      console.log(`💰 Balance: ${ethers.utils.formatEther(balance)} BNB`);
      
      // Test gas price
      const gasPrice = await provider.getGasPrice();
      console.log(`⛽ Gas price: ${ethers.utils.formatUnits(gasPrice, 'gwei')} gwei`);
      
      console.log(`✅ RPC endpoint ${rpcUrl} is working!`);
      return rpcUrl; // Return the working endpoint
      
    } catch (error) {
      console.log(`❌ RPC endpoint failed: ${error.message}`);
    }
  }
  
  console.log("❌ All RPC endpoints failed!");
  return null;
}

testBSCNetwork()
  .then((workingRpc) => {
    if (workingRpc) {
      console.log(`\n🎉 Best RPC endpoint: ${workingRpc}`);
    }
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Network test failed:", error);
    process.exit(1);
  });
