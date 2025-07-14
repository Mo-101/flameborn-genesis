#!/usr/bin/env python3

from web3 import Web3
import sys
import os
from dotenv import load_dotenv

def main():
    print("Starting Celo address verification (Python)...")
    
    # Load environment variables
    load_dotenv()
    
    # Get the address from command line or use the default one
    if len(sys.argv) > 1:
        address_to_verify = sys.argv[1]
    else:
        address_to_verify = '0x5B38Da6a701c568545dCfcB03FcB875f56beddC4'
    print(f"Using address: {address_to_verify}")

    # Using Alfajores testnet information as provided
    network_name = 'Celo Alfajores Testnet'
    chain_id = 44787
    rpc_url = os.getenv('CELO_ALFAJORES_RPC_URL', 'https://alfajores-forno.celo-testnet.org')
    explorer_url = 'https://explorer.celo.org/alfajores'
    
    print(f"Connecting to {network_name} (Chain ID: {chain_id}) at {rpc_url}...")
    
    # Connect to the Celo network
    web3 = Web3(Web3.HTTPProvider(rpc_url))
    
    if not web3.is_connected():
        print("❌ Failed to connect to the Celo network. Check your internet connection.")
        return
        
    print(f"\n🔍 Verifying address on {network_name}...")
    print(f"Address: {address_to_verify}")
    
    # Check if address is valid
    if not web3.is_address(address_to_verify):
        print("❌ Invalid Ethereum address format")
        return
    
    try:
        # Get basic account information
        print('Fetching account data...')
        balance = web3.eth.get_balance(address_to_verify)
        balance_in_celo = web3.from_wei(balance, 'ether')
        tx_count = web3.eth.get_transaction_count(address_to_verify)
        code = web3.eth.get_code(address_to_verify)
        is_contract = code != '0x'
        
        print('\n✅ Address verification results:')
        print('-----------------------------')
        print(f"Valid address: Yes")
        print(f"Balance: {balance_in_celo} CELO")
        print(f"Transaction count: {tx_count}")
        print(f"Type: {'Contract' if is_contract else 'Externally Owned Account (EOA)'}")
        
        if is_contract:
            print(f"Code size: {(len(code) - 2) // 2} bytes")

        # Display blockchain explorer link
        print(f"\nExplorer link: {explorer_url}/address/{address_to_verify}")
        
    except Exception as e:
        print(f"❌ Error verifying address: {str(e)}")
        print("Check your connection and ensure the address is on the Celo network")

if __name__ == "__main__":
    main()
