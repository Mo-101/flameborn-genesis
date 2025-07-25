require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    alfajores: {
      url: process.env.CELO_ALFAJORES_RPC_URL || 'https://alfajores-forno.celo-testnet.org',
      chainId: 44787,
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      alfajores: process.env.CELOSCAN_API_KEY || "DZC179W5TDKF5NXK3V2Y3VGCRCXEAVA8XN",
    },
    customChains: [
      {
        network: "alfajores",
        chainId: 44787,
        urls: {
          apiURL: "https://api-alfajores.celoscan.io/api",
          browserURL: "https://alfajores.celoscan.io"
        }
      }
    ]
  }
};
