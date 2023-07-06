import { expect } from 'chai'
import hre, {ethers} from 'hardhat'

describe("Controller", function() {

    async function deployAndSetupContracts() {
        const [ owner, addr1, addre2, addre3 ] = await ethers.getSigners();

        // Step 1. Deplot contracts

        const productTokenContract = await ethers.deployContract('ProductToken');
        const prescriptionTokenContract = await ethers.deployContract('PrescriptionToken');

        const Controller = await ethers.getContractFactory('Controller');
        const controller = await Controller.deploy();

        await productTokenContract.deployed();
        await prescriptionTokenContract.deployed();
        await controller.deployed();

        // Step 2. Define controller contract connections

        await controller.setProductTokenAddress(productTokenContract.address);
        await controller.setPrescriptionTokenAddress(prescriptionTokenContract.address);

        // Step 3. Give MINTER ROLE to the controller in ProductToken and PrescriptionToken

        await productTokenContract.grantRole(productTokenContract.MINTER_ROLE(), controller.address);
        await prescriptionTokenContract.grantRole(prescriptionTokenContract.MINTER_ROLE(), controller.address);

        return { controller, productTokenContract, prescriptionTokenContract, owner, addr1, addre2, addre3}
    }

    it("Crear un token de producto", async function () {
        const { controller, owner, addr1} = await deployAndSetupContracts();

        // const texto = ethers.utils.formatBytes32String('hola')

        // await controller.connect(owner).createProduct("texto", "texto", "texto", false, false, false, 5,5,5,5);
        await controller.createProduct("texto", "texto", "texto", false, false, false, 5,5,5,5);


        expect(((await controller.getProduct(0)).Name)).to.be.equal("texto");
    })
})