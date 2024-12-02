require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { ALCHEMI_KEY, PRIVATE_KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    },
    viaIR: true // Enable the IR-based compilation
  },
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMI_KEY}`,
      accounts: [PRIVATE_KEY],
    },
  },
};
