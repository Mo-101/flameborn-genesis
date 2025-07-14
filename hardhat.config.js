require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      viaIR: true // Use the new IR-based compiler pipeline for better optimizations
    }
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
    },
    alfajores: {
      url: process.env.CELO_ALFAJORES_RPC_URL || "https://alfajores-forno.celo-testnet.org",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    },
    celo: {
      url: process.env.CELO_MAINNET_RPC_URL || "https://forno.celo.org",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./contracts/artifacts"
  }
};
