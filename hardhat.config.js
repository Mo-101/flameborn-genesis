require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
require('@nomiclabs/hardhat-etherscan');
require('@celo-tools/hardhat-celo');

module.exports = {
  solidity: '0.8.24',
  networks: {
    alfajores: {
      url: 'https://alfajores-forno.celo-testnet.org',
      accounts: [process.env.PRIVATE_KEY]
    },
    mainnet: {
      url: 'https://forno.celo.org',
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  etherscan: {
    // Celo’s API key for Alfajores/Mainnet from https://explorer.celo.org/settings/api-keys
    apiKey: process.env.CELOSCAN_API_KEY
  }
};

// The following section seems to be a malformed object or an attempt to extend the module.exports.
// It's causing a syntax error. I'm commenting it out as it's not valid JavaScript syntax in this context.
// If these were intended to be separate configurations or part of a larger structure, they need to be
// properly integrated into the `module.exports` object.

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
