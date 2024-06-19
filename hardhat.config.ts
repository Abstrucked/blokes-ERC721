import "@nomicfoundation/hardhat-toolbox";
import "@xyrusworx/hardhat-solidity-json";
import "@nomicfoundation/hardhat-ignition";
import * as dotenv from  "dotenv";
import {HardhatConfig} from "hardhat/types";
dotenv.config();
const hychain = {
  accounts: [process.env.DEPLOYER_PRIVATE_KEY],
  url: "https://rpc.hychain.com/http",
  chainId: 2911,
  gas: 1000000,

}

const hychainTestnet = {
  url: "https://hytopia-testnet.rpc.caldera.xyz/http",
  chainId: 29112,
  accounts: [
    process.env.DEPLOYER_PRIVATE_KEY
  ]
}

const config = {
  solidity: "0.8.24",
  optimizer: {
    enabled: true,
    runs: 200
  },
  defaultNetwork: "hardhat",
  networks: {
    hychain: hychain,
    hychainTestnet: hychainTestnet,
  },
  ignition: {
    requiredConfirmations: 2,
  }
};

export default config;
