import { expect } from 'chai'
import hre, {ethers} from 'hardhat'

describe("Controller", function() {

    async function deployContracts() {
        const [ owner, addr1, addre2, addre3 ] = await ethers.getSigners();
        const productTokenContract = await ethers.deployContract('ProductToken');
        const prescriptionTokenContract = await ethers.deployContract('PrescriptionToken');

        const Controller = await ethers.getContractFactory('Controller')
        const controller = await Controller.deploy(prescriptionTokenContract.address ,productTokenContract.address)

        return { controller, productTokenContract, prescriptionTokenContract, owner, addr1, addre2, addre3}
    }

    it("Crear un token de producto", async function () {
        const { controller, productTokenContract, owner, addr1} = await deployContracts();

        const texto = ethers.utils.formatBytes32String('hola')
        // await productTokenContract.connect(owner).grantRoleMinter(controller.address);

        // await controller.connect(owner).createProduct(texto, texto, texto, false, false, false, 5,5,5);


        expect(((await controller.getProduct(0)).Name)).to.be.equal(texto);
    })
})