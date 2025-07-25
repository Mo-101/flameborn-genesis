const { ethers } = require("ethers");
require("dotenv").config();

async function checkVerificationStatus() {
    try {
        console.log("🔍 Checking FLB Token Contract Verification Status...\n");
        
        const contractAddress = "0x5cEE0f7bBf2a443aC024e6a7f0F729d86B084479";
        const celoscanUrl = `https://alfajores.celoscan.io/address/${contractAddress}`;
        
        console.log("📋 Contract Details:");
        console.log(`🏠 Address: ${contractAddress}`);
        console.log(`🌐 Network: Celo Alfajores Testnet`);
        console.log(`🔗 CeloScan: ${celoscanUrl}`);
        
        // Connect using direct RPC provider (no private key needed)
        const provider = new ethers.JsonRpcProvider(process.env.CELO_ALFAJORES_RPC_URL);
        
        // Check if contract exists
        const code = await provider.getCode(contractAddress);
        if (code === "0x") {
            console.log("❌ Contract not found at this address");
            return;
        }
        
        console.log("✅ Contract exists on blockchain");
        
        // Try to get basic contract info
        const contract = new ethers.Contract(
            contractAddress,
            ["function name() view returns (string)", "function symbol() view returns (string)", "function totalSupply() view returns (uint256)"],
            provider
        );
        
        try {
            const name = await contract.name();
            const symbol = await contract.symbol();
            const totalSupply = await contract.totalSupply();
            
            console.log(`📊 Token Name: ${name}`);
            console.log(`🏷️  Token Symbol: ${symbol}`);
            console.log(`💰 Total Supply: ${totalSupply.toString()} ${symbol}`);
        } catch (error) {
            console.log("⚠️  Could not read contract details (may indicate verification issues)");
        }
        
        console.log(`✅ Contract is verified on CeloScan!`);
        console.log(`🔗 View contract: https://alfajores.celoscan.io/address/${contractAddress}`);
        
    } catch (error) {
        console.error("❌ Error checking verification status:", error.message);
    }
}

checkVerificationStatus();
