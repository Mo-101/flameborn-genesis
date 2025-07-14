const Web3 = require('web3');
require('dotenv').config();

async function main() {
  try {
    console.log('Starting Celo address verification...');
    
    // Get the address from command line or use the default one
    const addressToVerify = process.argv[2] || '0x5B38Da6a701c568545dCfcB03FcB875f56beddC4';
    console.log(`Using address: ${addressToVerify}`);

    // Using Alfajores testnet information as provided
    const networkName = 'Celo Alfajores Testnet';
    const chainId = 44787;
    const rpcUrl = 'https://alfajores-forno.celo-testnet.org';
    const explorerUrl = 'https://explorer.celo.org/alfajores';
    
    console.log(`Connecting to ${networkName} (Chain ID: ${chainId}) at ${rpcUrl}...`);
    const web3 = new Web3(new Web3.providers.HttpProvider(rpcUrl));
    
    console.log(`\n🔍 Verifying address on ${networkName}...`);
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
    
    console.log('\n✅ Address verification results:');
    console.log('-----------------------------');
    console.log(`Valid address: Yes`);
    console.log(`Balance: ${balanceInCELO} CELO`);
    console.log(`Transaction count: ${txCount}`);
    console.log(`Type: ${isContract ? 'Contract' : 'Externally Owned Account (EOA)'}`);
    if (isContract) {
      console.log(`Code size: ${(code.length - 2) / 2} bytes`);
    }

    // Display blockchain explorer link
    console.log(`\nExplorer link: ${explorerUrl}/address/${addressToVerify}`);

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
