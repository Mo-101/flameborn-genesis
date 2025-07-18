require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomicfoundation/hardhat-verify");
require("@celo-tools/hardhat-celo");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: { enabled: true, runs: 200 },
      viaIR: true
    }
  },
  networks: {
    bsc: {
      url: process.env.BSC_MAINNET_RPC_URL || 'https://bsc-dataseed.binance.org/',
      chainId: 56,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    },
    bscTestnet: {
      url: process.env.BSC_TESTNET_RPC_URL || 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      chainId: 97,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    },
    alfajores: {
      url: process.env.CELO_ALFAJORES_RPC_URL || 'https://alfajores-forno.celo-testnet.org',
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    },
    celo: {
      url: process.env.CELO_MAINNET_RPC_URL || 'https://forno.celo.org',
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: {
      bsc: process.env.BSCSCAN_API_KEY || "",
      bscTestnet: process.env.BSCSCAN_API_KEY || "",
      alfajores: process.env.ETHERSCAN_API_KEY || "",
      celo: process.env.ETHERSCAN_API_KEY || ""
    },
    customChains: [
      {
        network: "bsc",
        chainId: 56,
        urls: {
          apiURL: "https://api.bscscan.com/api",
          browserURL: "https://bscscan.com"
        }
      },
      {
        network: "bscTestnet",
        chainId: 97,
        urls: {
          apiURL: "https://api-testnet.bscscan.com/api",
          browserURL: "https://testnet.bscscan.com"
        }
      },
      {
        network: 'alfajores',
        chainId: 44787,
        urls: {
          apiURL: 'https://alfajores.celoscan.io/api',
          browserURL: 'https://alfajores.celoscan.io'
        }
      },
      {
        network: 'celo',
        chainId: 42220,
        urls: {
          apiURL: 'https://explorer.celo.org/api',
          browserURL: 'https://explorer.celo.org'
        }
      }
    ]
  }
};

// {
//   {
//     false,
//   },
//   {
//     process.env.CELO_ALFAJORES_RPC_URL || "https://alfajores-forno.celo-testnet.org",
//     accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
//   },
//   {
//     process.env.CELO_MAINNET_RPC_URL || "https://forno.celo.org",
//     accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : ["0x2e75287c542b9b111906d961d58f2617059dde3c"]
//   }
// },
// {
//   {
//     process.env.ETHERSCAN_API_KEY,
//     celo: process.env.ETHERSCAN_API_KEY
//   },
//   [
//     {
//       network: "alfajores",
//       chainId: 44787,
//       urls: {
//         apiURL: "https://alfajores.celoscan.io/api",
//         browserURL: "https://alfajores.celoscan.io"
//       }
//     },
//     {
//       network: "celo",
//       chainId: 42220,
//       urls: {
//         apiURL: "https://explorer.celo.org/api",
//         browserURL: "https://explorer.celo.org"
//       }
//     }
//   ]
// },
// {
//   "./contracts",
//   tests: "./test",
//   cache: "./cache",
//   artifacts: "./contracts/artifacts"
// }
