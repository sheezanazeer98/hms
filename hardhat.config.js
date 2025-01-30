require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("dotenv").config();

module.exports = {
  solidity: "0.8.24",
  defaultNetwork: "localhost",
  networks: {
    polygon: {
      chainId: 137,
      url: process.env.POLYGON_PROVIDER_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    sepolia: {
      chainId: 11155111,
      url: process.env.SEPOLIA_PROVIDER_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    amoy: {
      chainId: 80002,
      url: process.env.AMOY_PROVIDER_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      polygon: process.env.POLYGON_ETHERSCAN_API_KEY,
      sepolia: process.env.SEPOLIA_ETHERSCAN_API_KEY,
      amoy: process.env.AMOY_ETHERSCAN_API_KEY,
    },
    customChains: [
      {
        network: "polygon",
        chainId: 137,
        urls: {
          apiURL: "https://api.polygonscan.com/api",
          browserURL: "https://polygonscan.com",
        },
      },
      {
        network: "sepolia",
        chainId: 11155111,
        urls: {
          apiURL: "https://api-sepolia.etherscan.io/api",
          browserURL: "https://sepolia.etherscan.io",
        },
      },
      {
        network: "amoy",
        chainId: 80002,
        urls: {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: "https://amoy.polygonscan.com",
        },
      },
    ],
  },
};
