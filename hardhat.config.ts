import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@nomiclabs/hardhat-ethers';
import "dotenv/config";

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  networks: {
    fuji: {
      url: process.env.INFURA_NODE_ENDPOINT,
      gasPrice: 225000000000,
      chainId: 43113,
      accounts: [`0x${process.env.WALLET_PRIVATE_KEY}`]
    }
  }
};

export default config;
