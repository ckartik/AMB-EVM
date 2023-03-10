require("@nomicfoundation/hardhat-toolbox");
require('solidity-coverage')
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.API_KEY}`,
      accounts: [process.env.PRIV_KEY1, process.env.PRIV_KEY2],
    },
  },
  mocha: {
    timeout: 100000000
  },
};
