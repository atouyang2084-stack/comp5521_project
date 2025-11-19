require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    // 本地开发网络
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    // 如果需要连接到测试网（可选）
//    sepolia: {
  //    url: process.env.ALCHEMY_API_KEY ? 
    //       `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}` : 
      //     "",
     // accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
   // }
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test"
  }
};
