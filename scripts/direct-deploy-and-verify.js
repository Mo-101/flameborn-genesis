// Direct deployment and verification script with file logging
require('dotenv').config();
const fs = require('fs');
const ethers = require('ethers');
const path = require('path');

// Get contract JSON from artifacts
function getContractArtifact(contractName) {
  const artifactPath = path.join(
    __dirname, 
    '../artifacts/contracts/FlameBornToken.sol', 
    `${contractName}.json`
  );
  
  if (!fs.existsSync(artifactPath)) {
    throw new Error(`Contract artifact not found at ${artifactPath}`);
  }
  
  return JSON.parse(fs.readFileSync(artifactPath, 'utf8'));
}

// Setup logging to both console and file
function setupLogging() {
  const logDir = path.join(__dirname, '../logs');
  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir);
  }
  
  const logFile = path.join(logDir, `deployment-${new Date().toISOString().replace(/:/g, '-')}.log`);
  const logStream = fs.createWriteStream(logFile, { flags: 'a' });
  
  // Log to both console and file
  const originalConsoleLog = console.log;
  console.log = function() {
    const args = Array.from(arguments);
    const logMessage = args.map(arg => 
      typeof arg === 'object' ? JSON.stringify(arg, null, 2) : arg
    ).join(' ');
    
    logStream.write(logMessage + '\n');
    originalConsoleLog.apply(console, arguments);
  };
  
  const originalConsoleError = console.error;
  console.error = function() {
    const args = Array.from(arguments);
    const logMessage = args.map(arg => 
      typeof arg === 'object' ? JSON.stringify(arg, null, 2) : arg
    ).join(' ');
    
    logStream.write('[ERROR] ' + logMessage + '\n');
    originalConsoleError.apply(console, arguments);
  };
  
  return logFile;
}

async function deploy(networkName) {
  const logFile = setupLogging();
  console.log(`\n=============================================`);
  console.log(`DEPLOYMENT STARTED at ${new Date().toISOString()}`);
  console.log(`Network: ${networkName}`);
  console.log(`Logs saved to: ${logFile}`);
  console.log(`=============================================\n`);
  
  try {
    // Get private key from .env
    const privateKey = process.env.PRIVATE_KEY;
    if (!privateKey) {
      throw new Error('PRIVATE_KEY not found in .env file');
    }
    
    // Get RPC URL based on network
    let rpcUrl;
    if (networkName === 'alfajores') {
      rpcUrl = process.env.CELO_ALFAJORES_RPC_URL;
    } else if (networkName === 'celo') {
      rpcUrl = process.env.CELO_MAINNET_RPC_URL;
    } else {
      throw new Error(`Unsupported network: ${networkName}`);
    }
    
    if (!rpcUrl) {
      throw new Error(`RPC URL for ${networkName} not found in .env file`);
    }
    
    // Setup provider and signer
    console.log(`[1/5] Setting up provider for ${networkName}...`);
    const provider = new ethers.JsonRpcProvider(rpcUrl);
    const wallet = new ethers.Wallet(privateKey, provider);
    console.log(`   > Deployer address: ${wallet.address}`);
    
    // Check balance
    console.log('[2/5] Checking account balance...');
    const balance = await provider.getBalance(wallet.address);
    console.log(`   > Balance: ${ethers.formatEther(balance)} CELO`);
    
    if (balance === 0n) {
      throw new Error('Deployer account has zero balance. Please fund the account before deployment.');
    }
    
    // Get contract bytecode and ABI
    console.log('[3/5] Preparing contract for deployment...');
    const contractArtifact = getContractArtifact('FlameBornToken');
    const abi = contractArtifact.abi;
    const bytecode = contractArtifact.bytecode;
    
    // Deploy contract
    console.log('[4/5] Deploying FlameBornToken...');
    const contractFactory = new ethers.ContractFactory(abi, bytecode, wallet);
    
    const initialSupply = 1000000;
    console.log(`   > Initial supply: ${initialSupply}`);
    
    const deployTransaction = await contractFactory.getDeployTransaction(initialSupply);
    console.log(`   > Estimated gas: ${deployTransaction.gasLimit}`);
    
    console.log('   > Sending transaction...');
    const tx = await wallet.sendTransaction(deployTransaction);
    console.log(`   > Transaction hash: ${tx.hash}`);
    
    console.log('   > Waiting for transaction confirmation...');
    const receipt = await tx.wait(2); // Wait for 2 confirmations
    
    const contractAddress = receipt.contractAddress;
    console.log('[5/5] Contract deployed successfully!');
    console.log(`   > Contract address: ${contractAddress}`);
    console.log(`   > Block number: ${receipt.blockNumber}`);
    console.log(`   > Gas used: ${receipt.gasUsed}`);
    
    // Save deployment info
    const deploymentDir = path.join(__dirname, '../deployments');
    if (!fs.existsSync(deploymentDir)) {
      fs.mkdirSync(deploymentDir);
    }
    
    const deploymentInfo = {
      network: networkName,
      contractAddress: contractAddress,
      deployer: wallet.address,
      initialSupply: initialSupply,
      transactionHash: tx.hash,
      blockNumber: receipt.blockNumber,
      timestamp: new Date().toISOString()
    };
    
    const deploymentFile = path.join(deploymentDir, `deployment-${networkName}.json`);
    fs.writeFileSync(deploymentFile, JSON.stringify(deploymentInfo, null, 2));
    console.log(`\nDeployment information saved to: ${deploymentFile}`);
    
    // Generate verification command
    if (networkName === 'alfajores') {
      console.log(`\n📋 Verification command for CeloScan:\nnpx hardhat verify --network ${networkName} ${contractAddress} ${initialSupply}`);
    } else {
      console.log(`\n📋 Verification command for CeloScan:\nnpx hardhat verify --network ${networkName} ${contractAddress} ${initialSupply}`);
    }
    
    return {
      success: true,
      contractAddress,
      network: networkName
    };
  } catch (error) {
    console.error("\n❌ DEPLOYMENT FAILED");
    console.error("=============================================");
    console.error(error);
    console.error("=============================================\n");
    return {
      success: false,
      error: error.message
    };
  }
}

// Run deployment if this script is executed directly
if (require.main === module) {
  // Get network name from command line arguments
  const args = process.argv.slice(2);
  const networkName = args[0] || 'alfajores'; // Default to alfajores if not specified
  
  if (!['alfajores', 'celo'].includes(networkName)) {
    console.error(`Invalid network: ${networkName}. Must be 'alfajores' or 'celo'`);
    process.exit(1);
  }
  
  deploy(networkName)
    .then((result) => {
      if (result.success) {
        console.log(`\n✅ Deployment to ${result.network} completed successfully!`);
        console.log(`   > Contract address: ${result.contractAddress}`);
      } else {
        console.log(`\n❌ Deployment failed: ${result.error}`);
        process.exit(1);
      }
    })
    .catch((error) => {
      console.error('\nUnexpected error:', error);
      process.exit(1);
    });
}

module.exports = deploy;
