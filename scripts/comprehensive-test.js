const { ethers } = require("ethers");
require("dotenv").config();
const fs = require("fs");

// Main contract details
const CONTRACT_ADDRESS = "0x93F4c3B97aa4706e0a84f7667eB7f356F138dC60";

// FlameBornToken ABI (simplified to include the main functions we want to test)
const abi = [
  // Basic ERC20 functions
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "function decimals() view returns (uint8)",
  "function totalSupply() view returns (uint256)",
  "function balanceOf(address) view returns (uint256)",
  "function transfer(address to, uint256 amount) returns (bool)",
  
  // Access Control functions
  "function hasRole(bytes32 role, address account) view returns (bool)",
  "function getRoleAdmin(bytes32 role) view returns (bytes32)",
  "function grantRole(bytes32 role, address account)",
  "function revokeRole(bytes32 role, address account)",
  
  // FlameBornToken specific functions
  "function registerAfricanID(address account, string calldata idHash)",
  "function mintAfterValidation(address to, uint256 amount, string calldata proof)",
  "function verifyByTribalCouncil(address user)",
  "function approveAndStoreBiometricHash(bytes32 biometricHash)",
  "function verifyByBiometrics(address user, bytes32 biometricHash)",
  "function verifyByAncestryProof(address user, bytes32 proofHash)",
  "function rewardYouthAction(address youth, uint256 amount, string calldata action)",
  "function issueSoulprint(address user, string memory hash, uint256 weight)",
  "function burnTokens(uint256 amount)",
  "function isSoulbound(address user) view returns (bool)",
  
  // Role constants
  "function DAO_ROLE() view returns (bytes32)",
  "function VALIDATOR_ROLE() view returns (bytes32)",
  "function YOUTH_ROLE() view returns (bytes32)",
  "function ELDER_ROLE() view returns (bytes32)",
  "function TRIBAL_COUNCIL_ROLE() view returns (bytes32)"
];

// Setup wallets array
const TEST_WALLETS_COUNT = 30;

// Helper function to create a random ID for testing
function generateRandomAfricanID() {
  return `AFR-ID-${Math.floor(Math.random() * 1000000)}`;
}

// Helper function to generate a random bytes32 hash
function generateRandomBytes32() {
  const randomBytes = ethers.randomBytes(32);
  return ethers.keccak256(randomBytes);
}

// Helper function to create delay between transactions to avoid rate limiting
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
  // Setup provider and admin wallet
  console.log("Connecting to Celo Alfajores testnet...");
  const provider = new ethers.JsonRpcProvider(process.env.CELO_ALFAJORES_RPC_URL);
  const adminWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  console.log(`Admin wallet address: ${adminWallet.address}`);
  
  // Connect to contract as admin
  const flameBornToken = new ethers.Contract(CONTRACT_ADDRESS, abi, adminWallet);
  
  // Initialize test results tracking
  const testResults = {
    successfulTests: 0,
    failedTests: 0,
    details: []
  };

  // Record test result helper function
  function recordTestResult(testName, success, details = "") {
    if (success) {
      testResults.successfulTests++;
      console.log(`✅ ${testName} - SUCCESS`);
    } else {
      testResults.failedTests++;
      console.log(`❌ ${testName} - FAILED: ${details}`);
    }
    testResults.details.push({
      testName,
      success,
      details: details || "No additional details"
    });
  }

  try {
    // --- STEP 1: Get basic token info ---
    console.log("\n=== BASIC TOKEN INFORMATION ===");
    try {
      const name = await flameBornToken.name();
      const symbol = await flameBornToken.symbol();
      const decimals = await flameBornToken.decimals();
      const totalSupply = await flameBornToken.totalSupply();
      
      console.log(`Name: ${name}`);
      console.log(`Symbol: ${symbol}`);
      console.log(`Decimals: ${decimals}`);
      console.log(`Total Supply: ${ethers.formatUnits(totalSupply, decimals)}`);
      recordTestResult("Get Token Info", true);
    } catch (error) {
      recordTestResult("Get Token Info", false, error.message);
    }

    // --- STEP 2: Generate test wallets ---
    console.log("\n=== GENERATING TEST WALLETS ===");
    const wallets = [];
    for (let i = 0; i < TEST_WALLETS_COUNT; i++) {
      const wallet = ethers.Wallet.createRandom().connect(provider);
      wallets.push(wallet);
      console.log(`Wallet ${i+1}: ${wallet.address}`);
    }
    recordTestResult("Generate Test Wallets", true, `Created ${TEST_WALLETS_COUNT} wallets`);
    
    // --- STEP 3: Fund wallets with test CELO ---
    console.log("\n=== FUNDING TEST WALLETS WITH CELO ===");
    console.log("Funding first 5 wallets for testing (remaining will be used without funding)...");
    
    for (let i = 0; i < 5; i++) {
      try {
        // Send a small amount of CELO to each test wallet for gas
        const tx = await adminWallet.sendTransaction({
          to: wallets[i].address,
          value: ethers.parseEther("0.1") // 0.1 CELO
        });
        console.log(`Funded wallet ${i+1} (${wallets[i].address.substring(0, 8)}...), tx: ${tx.hash}`);
        await delay(2000); // Wait 2 seconds between funding transactions
      } catch (error) {
        console.log(`Failed to fund wallet ${i+1}: ${error.message}`);
      }
    }
    
    // --- STEP 4: Setup roles ---
    console.log("\n=== SETTING UP ROLES ===");
    
    // Get role identifiers
    const DAO_ROLE = await flameBornToken.DAO_ROLE();
    const VALIDATOR_ROLE = await flameBornToken.VALIDATOR_ROLE();
    const YOUTH_ROLE = await flameBornToken.YOUTH_ROLE();
    const ELDER_ROLE = await flameBornToken.ELDER_ROLE();
    const TRIBAL_COUNCIL_ROLE = await flameBornToken.TRIBAL_COUNCIL_ROLE();
    
    console.log(`DAO_ROLE: ${DAO_ROLE}`);
    console.log(`VALIDATOR_ROLE: ${VALIDATOR_ROLE}`);
    console.log(`YOUTH_ROLE: ${YOUTH_ROLE}`);
    console.log(`ELDER_ROLE: ${ELDER_ROLE}`);
    console.log(`TRIBAL_COUNCIL_ROLE: ${TRIBAL_COUNCIL_ROLE}`);
    
    // Assign roles to different wallets
    const roleAssignments = [
      { role: DAO_ROLE, wallet: wallets[0], name: "DAO" },
      { role: VALIDATOR_ROLE, wallet: wallets[1], name: "Validator" },
      { role: TRIBAL_COUNCIL_ROLE, wallet: wallets[2], name: "Tribal Council" },
      { role: ELDER_ROLE, wallet: wallets[3], name: "Elder" },
      { role: YOUTH_ROLE, wallet: wallets[4], name: "Youth" }
    ];
    
    for (const assignment of roleAssignments) {
      try {
        // Check if admin has permission to grant roles first
        const adminRole = await flameBornToken.getRoleAdmin(assignment.role);
        const hasAdminRole = await flameBornToken.hasRole(adminRole, adminWallet.address);
        
        if (hasAdminRole) {
          const tx = await flameBornToken.grantRole(assignment.role, assignment.wallet.address);
          console.log(`Granted ${assignment.name} role to wallet ${assignment.wallet.address}`);
          await tx.wait();
          await delay(2000); // Wait 2 seconds between role assignments
          recordTestResult(`Grant ${assignment.name} Role`, true);
        } else {
          console.log(`Admin does not have permission to grant ${assignment.name} role`);
          recordTestResult(`Grant ${assignment.name} Role`, false, "Admin doesn't have permission");
        }
      } catch (error) {
        recordTestResult(`Grant ${assignment.name} Role`, false, error.message);
      }
    }
    
    // --- STEP 5: Test African ID Registration ---
    console.log("\n=== TESTING AFRICAN ID REGISTRATION ===");
    
    // Connect contract with validator wallet
    const validatorContract = flameBornToken.connect(wallets[1]);
    
    // Test registering African IDs for 5 wallets
    for (let i = 5; i < 10; i++) {
      try {
        const randomID = generateRandomAfricanID();
        const tx = await validatorContract.registerAfricanID(wallets[i].address, randomID);
        await tx.wait();
        console.log(`Registered African ID ${randomID} for wallet ${wallets[i].address}`);
        recordTestResult(`Register African ID for Wallet ${i+1}`, true);
        await delay(2000); // Wait 2 seconds between registrations
      } catch (error) {
        recordTestResult(`Register African ID for Wallet ${i+1}`, false, error.message);
      }
    }
    
    // --- STEP 6: Test Verification Methods ---
    console.log("\n=== TESTING VERIFICATION METHODS ===");
    
    // Test tribal council verification
    try {
      const tribalCouncilContract = flameBornToken.connect(wallets[2]);
      const tx = await tribalCouncilContract.verifyByTribalCouncil(wallets[10].address);
      await tx.wait();
      console.log(`Verified wallet ${wallets[10].address} by tribal council`);
      recordTestResult("Tribal Council Verification", true);
    } catch (error) {
      recordTestResult("Tribal Council Verification", false, error.message);
    }
    
    // Test biometric verification
    try {
      const validatorContract = flameBornToken.connect(wallets[1]);
      const biometricHash = generateRandomBytes32();
      
      // First approve the hash
      const approveTx = await validatorContract.approveAndStoreBiometricHash(biometricHash);
      await approveTx.wait();
      console.log(`Approved biometric hash: ${biometricHash}`);
      
      // Then verify a user with it
      const verifyTx = await validatorContract.verifyByBiometrics(wallets[11].address, biometricHash);
      await verifyTx.wait();
      console.log(`Verified wallet ${wallets[11].address} by biometrics`);
      recordTestResult("Biometric Verification", true);
    } catch (error) {
      recordTestResult("Biometric Verification", false, error.message);
    }
    
    // Test ancestry proof verification
    try {
      const validatorContract = flameBornToken.connect(wallets[1]);
      const ancestryProofHash = generateRandomBytes32();
      const verifyTx = await validatorContract.verifyByAncestryProof(wallets[12].address, ancestryProofHash);
      await verifyTx.wait();
      console.log(`Verified wallet ${wallets[12].address} by ancestry proof`);
      recordTestResult("Ancestry Proof Verification", true);
    } catch (error) {
      recordTestResult("Ancestry Proof Verification", false, error.message);
    }
    
    // --- STEP 7: Test Minting After Validation ---
    console.log("\n=== TESTING MINTING AFTER VALIDATION ===");
    
    try {
      const validatorContract = flameBornToken.connect(wallets[1]);
      const mintAmount = ethers.parseUnits("100", 18); // 100 tokens
      const proof = "Validation_Proof_" + Date.now();
      const tx = await validatorContract.mintAfterValidation(wallets[13].address, mintAmount, proof);
      await tx.wait();
      console.log(`Minted ${ethers.formatUnits(mintAmount, 18)} tokens to wallet ${wallets[13].address}`);
      
      // Check the balance
      const balance = await flameBornToken.balanceOf(wallets[13].address);
      console.log(`New balance: ${ethers.formatUnits(balance, 18)} tokens`);
      recordTestResult("Mint After Validation", true);
    } catch (error) {
      recordTestResult("Mint After Validation", false, error.message);
    }
    
    // --- STEP 8: Test Youth Action Reward ---
    console.log("\n=== TESTING YOUTH ACTION REWARD ===");
    
    try {
      const elderContract = flameBornToken.connect(wallets[3]);
      const rewardAmount = ethers.parseUnits("50", 18); // 50 tokens
      const actionDesc = "Community service participation";
      const tx = await elderContract.rewardYouthAction(wallets[4].address, rewardAmount, actionDesc);
      await tx.wait();
      console.log(`Rewarded ${ethers.formatUnits(rewardAmount, 18)} tokens to youth wallet ${wallets[4].address}`);
      
      // Check the balance
      const balance = await flameBornToken.balanceOf(wallets[4].address);
      console.log(`Youth balance: ${ethers.formatUnits(balance, 18)} tokens`);
      recordTestResult("Youth Action Reward", true);
    } catch (error) {
      recordTestResult("Youth Action Reward", false, error.message);
    }
    
    // --- STEP 9: Test Transfer Restrictions (Soulbound) ---
    console.log("\n=== TESTING TRANSFER RESTRICTIONS (SOULBOUND) ===");
    
    // First mint some tokens to test wallet
    try {
      const validatorContract = flameBornToken.connect(wallets[1]);
      const mintAmount = ethers.parseUnits("100", 18); // 100 tokens
      const proof = "Transfer_Test_" + Date.now();
      const tx = await validatorContract.mintAfterValidation(wallets[14].address, mintAmount, proof);
      await tx.wait();
      console.log(`Minted ${ethers.formatUnits(mintAmount, 18)} tokens to wallet ${wallets[14].address}`);
      
      // Now try to transfer (should fail if soulbound)
      const testWallet = flameBornToken.connect(wallets[14]);
      const transferAmount = ethers.parseUnits("10", 18); // 10 tokens
      
      // Check if soulbound
      const isSoulbound = await flameBornToken.isSoulbound(wallets[14].address);
      console.log(`Wallet ${wallets[14].address} is soulbound: ${isSoulbound}`);
      
      if (isSoulbound) {
        // This should fail
        try {
          await testWallet.transfer(wallets[15].address, transferAmount);
          recordTestResult("Soulbound Transfer Restriction", false, "Transfer should have failed but succeeded");
        } catch (error) {
          console.log(`Transfer correctly failed: ${error.message}`);
          recordTestResult("Soulbound Transfer Restriction", true, "Transfer failed as expected");
        }
      } else {
        console.log("Wallet is not soulbound, testing transfer");
        try {
          const tx = await testWallet.transfer(wallets[15].address, transferAmount);
          await tx.wait();
          console.log(`Transferred ${ethers.formatUnits(transferAmount, 18)} tokens to wallet ${wallets[15].address}`);
          recordTestResult("ERC20 Transfer", true);
        } catch (error) {
          recordTestResult("ERC20 Transfer", false, error.message);
        }
      }
    } catch (error) {
      recordTestResult("Transfer Test Setup", false, error.message);
    }
    
    // --- STEP 10: Test Burning Tokens ---
    console.log("\n=== TESTING TOKEN BURNING ===");
    
    try {
      // First mint some tokens to a wallet that will burn
      const validatorContract = flameBornToken.connect(wallets[1]);
      const mintAmount = ethers.parseUnits("100", 18); // 100 tokens
      const proof = "Burn_Test_" + Date.now();
      const tx = await validatorContract.mintAfterValidation(wallets[16].address, mintAmount, proof);
      await tx.wait();
      console.log(`Minted ${ethers.formatUnits(mintAmount, 18)} tokens to wallet ${wallets[16].address}`);
      
      // Now burn some tokens
      const burnerWallet = flameBornToken.connect(wallets[16]);
      const burnAmount = ethers.parseUnits("50", 18); // 50 tokens
      const burnTx = await burnerWallet.burnTokens(burnAmount);
      await burnTx.wait();
      console.log(`Burned ${ethers.formatUnits(burnAmount, 18)} tokens from wallet ${wallets[16].address}`);
      
      // Check the balance
      const balance = await flameBornToken.balanceOf(wallets[16].address);
      console.log(`New balance after burn: ${ethers.formatUnits(balance, 18)} tokens`);
      recordTestResult("Token Burning", true);
    } catch (error) {
      recordTestResult("Token Burning", false, error.message);
    }
    
    // --- STEP 11: Summary of Test Results ---
    console.log("\n=== TEST RESULTS SUMMARY ===");
    console.log(`Total Tests: ${testResults.successfulTests + testResults.failedTests}`);
    console.log(`Successful: ${testResults.successfulTests}`);
    console.log(`Failed: ${testResults.failedTests}`);
    console.log(`Success Rate: ${Math.round((testResults.successfulTests / (testResults.successfulTests + testResults.failedTests)) * 100)}%`);
    
    // Save test results to a file
    fs.writeFileSync(
      './flameBornToken-test-results.json', 
      JSON.stringify({
        timestamp: new Date().toISOString(),
        contract: CONTRACT_ADDRESS,
        network: "Celo Alfajores",
        results: testResults
      }, null, 2)
    );
    console.log("Test results saved to flameBornToken-test-results.json");
    
  } catch (error) {
    console.error("Fatal error in test script:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Unhandled error:", error);
    process.exit(1);
  });
