import hre, { ethers } from "hardhat";

async function main() {

  const Controller = await ethers.getContractFactory("Controller");
  // const controller = await Controller.deploy()
  const controller = await ethers.deployContract("Controller");


  await controller.deployed()

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
