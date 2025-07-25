const Web3 = require('web3');
require('dotenv').config();

async function main() {
  try {
    console.log('Starting address verification...');
    
    // Get the address from command line or use the default one
    const addressToVerify = process.argv[2] || '0x5cEE0f7bBf2a443aC024e6a7f0F729d86B084479';
    console.log(`Using address: ${addressToVerify}`);

    // Determine which network to connect to (default to alfajores testnet if not specified)
    const networkArg = process.argv[3] || 'alfajores';
    const isMainnet = networkArg.toLowerCase() === 'mainnet' || networkArg.toLowerCase() === 'celo';
    const networkName = isMainnet ? 'Celo Mainnet' : 'Celo Alfajores Testnet';
    
    // Set up Web3 with the appropriate RPC URL
    const rpcUrl = isMainnet 
      ? (process.env.CELO_MAINNET_RPC_URL || 'https://forno.celo.org')
      : (process.env.CELO_ALFAJORES_RPC_URL || 'https://alfajores-forno.celo-testnet.org');
    
    console.log(`Connecting to ${networkName} at ${rpcUrl}...`);
    const web3 = new Web3(new Web3.providers.HttpProvider(rpcUrl));
    
    console.log(`
🔍 Verifying address on ${networkName}...`);
    console.log(`Address: ${addressToVerify}`);
    
    // Check if address is valid
    if (!web3.utils.isAddress(addressToVerify)) {
      console.error('❌ Invalid Ethereum address format');
      return;
    }
    
    // Get basic account information
    console.log('Fetching account data...');
    const balance = await web3.eth.getBalance(addressToVerify);
    const balanceInCELO = web3.utils.fromWei(balance, 'ether');
    const txCount = await web3.eth.getTransactionCount(addressToVerify);
    const code = await web3.eth.getCode(addressToVerify);
    const isContract = code !== '0x';
    
    console.log('\n');
    console.log('✅ Address verification completed');
    console.log('-----------------------------');
    console.log(`Valid address: Yes`);
    console.log(`Balance: ${balanceInCELO} CELO`);
    console.log(`Transaction count: ${txCount}`);
    console.log(`Type: ${isContract ? 'Contract' : 'Externally Owned Account (EOA)'}`);

    // Display blockchain explorer link
    const explorerUrl = isMainnet 
      ? `https://explorer.celo.org/address/${addressToVerify}`
      : `https://alfajores.celoscan.io/address/${addressToVerify}`;
    console.log(`
Explorer link: ${explorerUrl}`);

  } catch (error) {
    console.error('❌ Error verifying address:', error);
    console.error('Make sure you have the Web3 package installed. Run: npm install web3');
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
