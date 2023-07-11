// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./PrescriptionToken.sol";
import "./ProductToken.sol";

contract Controller is AccessControl, Pausable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    PrescriptionToken private prescriptionToken;
    ProductToken private productToken;
    mapping(address => mapping(address => mapping(uint => uint))) public approvedTokensToTransfer ;

    event productCreated();
    event prescriptionCreated();
    event purchasedProduct();
    event soldProduct();

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Restricted to admins"
        );
        _;
    }

    modifier onlyMiner() {
        require(hasRole(MINTER_ROLE, msg.sender), "Restricted to miners");
        _;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpaused() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function createProduct(
        string memory _productName,
        string memory _productDescription,
        string memory _productLot,
        bool _productPharmaService,
        bool _productHospitalService,
        bool _productAuthorization,
        uint256 _productQuantity,
        uint256 _productExpireDate,
        uint256 _productPrice,
        uint256 _purchaseQuantity
    ) public onlyMiner {
        address originalSender = msg.sender;
        ProductToken.Product memory _product = ProductToken.Product(
            _productName,
            _productDescription,
            _productLot,
            _productQuantity,
            _productExpireDate,
            _productPrice,
            _productPharmaService,
            _productHospitalService,
            _productAuthorization
        );
        productToken.mint(originalSender, _purchaseQuantity, _product);
        emit productCreated();
    }

    function createPrescription(
        address to,
        uint256 productId,
        uint256 amountToTake,
        uint256 coolDownHours,
        uint256 productQuantity
    ) public onlyMiner {
        prescriptionToken.safeMint(
            to,
            productId,
            amountToTake,
            coolDownHours,
            productQuantity
        );
        emit prescriptionCreated();
    }

    function buyProduct(
        address seller,
        uint256 productId,
        uint256 amount,
        uint256 prescriptionId
    ) external payable {
        // ProductToken.Product memory _product = getProduct(productId);
        // if (_product.NeedAuthorization) {
        //     // TODO: Check Prescription
        //     PrescriptionToken.Prescription
        //         memory _prescription = getPrescription(prescriptionId);
        //     require(
        //         _prescription.productId == productId,
        //         "Prescription is not valid."
        //     );
        //     require(
        //         _prescription.productQuantity <= amount,
        //         "Can not buy that quantity"
        //     );
        // }
        // require(
        //     productToken.balanceOf(seller, productId) >= amount,
        //     "Not enought product to sell"
        // );
        // require(msg.value >= _product.Price * amount, "Not enough money.");
        // productToken.safeTransferFrom(seller, msg.sender, productId, amount, "");
        // emit purchasedProduct();

        ProductToken.Product memory _product = getProduct(productId);
        if (_product.NeedAuthorization) {
            PrescriptionToken.Prescription
                memory _prescription = getPrescription(prescriptionId);
            require(
                _prescription.productId == productId,
                "Prescription is not valid."
            );
            require(
                _prescription.productQuantity <= amount,
                "Can not buy that quantity"
            );
        }
        require(approvedTokensToTransfer[seller][address(productToken)][productId] >= amount, "Must not sell this product");
        require(
            productToken.balanceOf(seller, productId) >= amount,
            "Not enought product to sell"
        );
        // require(msg.value >= _product.Price * amount, "Not enough money."); // Pendiente de agregar
        approvedTokensToTransfer[seller][address(productToken)][productId] -= amount;
        productToken.safeTransferFrom(seller, msg.sender, productId, amount, "");
        emit purchasedProduct();
    }

    function sellProduct(
        uint256 productId,
        uint256 amount
    ) external payable {
        // ProductToken.Product memory _product = getProduct(productId);
        // require(
        //     _product.NeedAuthorization == false,
        //     "Must not sell this product"
        // );
        // require(
        //     productToken.balanceOf(seller, productId) >= amount,
        //     "Not enought product to sell"
        // );
        // require(msg.value >= _product.Price * amount, "Not enought money");

        // productToken.safeTransferFrom(seller, buyer, productId, amount, "");
        // emit soldProduct();
        ProductToken.Product memory _product = getProduct(productId);
        require(_product.NeedAuthorization == false || hasRole(MINTER_ROLE, msg.sender), "Must not sell this product.");
        require(productToken.balanceOf(msg.sender, productId) >= amount, "Not enought product to sell.");
        // Control del dinero enviado
        approvedTokensToTransfer[msg.sender][address(productToken)][productId] = amount;

        // productToken.safeTransferFrom(msg.sender, address(this), productId, amount, "");
        emit soldProduct();
    }

    function getProduct(
        uint256 tokenId
    ) public view returns (ProductToken.Product memory) {
        ProductToken.Product memory _product = productToken.getData(tokenId);
        return _product;
    }

    function getPrescription(
        uint256 tokenId
    ) public view returns (PrescriptionToken.Prescription memory) {
        return prescriptionToken.get(tokenId, msg.sender);
    }

    function setProductTokenAddress(address _productToken) external onlyAdmin {
        productToken = ProductToken(_productToken);
    }

    function setPrescriptionTokenAddress(address _prescriptionToken) external onlyAdmin {
        prescriptionToken = PrescriptionToken(_prescriptionToken);
    }
}
