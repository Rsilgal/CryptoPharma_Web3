import hre, { ethers } from "hardhat";

async function main() {

  const productTokenContract = await ethers.deployContract('ProductToken');
  const prescriptionTokenContract = await ethers.deployContract('PrescriptionToken');

  const Controller = await ethers.getContractFactory('Controller')
  const controller = await Controller.deploy();

  await controller.deployed()

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
