// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";
import "./PrescriptionToken.sol";
import "./ProductToken.sol";

contract Controller is AccessControl, Pausable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINER_ROLE = keccak256("MINER_ROLE");
    PrescriptionToken private prescriptionToken;
    ProductToken private productToken;

    constructor(address _prescriptionToken, address _productToken) {
        prescriptionToken = PrescriptionToken(_prescriptionToken);
        productToken = ProductToken(_productToken);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINER_ROLE, msg.sender);
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
        require(hasRole(MINER_ROLE, msg.sender), "Restricted to miners");
        _;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpaused() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function createProduct(
        bytes32 _productName,
        bytes32 _productDescription,
        bytes32 _productLot,
        bool _productPharmaService,
        bool _productHospitalService,
        bool _productAuthorization,
        uint256 _productQuantity,
        uint256 _productExpireDate,
        uint256 _productPrice
    ) public {
        productToken.safeMint(
            _productName,
            _productDescription,
            _productLot,
            _productPharmaService,
            _productHospitalService,
            _productAuthorization,
            _productQuantity,
            _productExpireDate,
            _productPrice
        );
    }

    function createPrescription(
        address to,
        uint256 productId,
        uint256 amountToTake,
        uint256 coolDownHours,
        uint256 productQuantity
    ) public onlyMiner() {
        prescriptionToken.safeMint(
            to,
            productId,
            amountToTake,
            coolDownHours,
            productQuantity
        );
    }

    // TODO: Only this contract must create nfts
    function buyProduct(uint256 productId, uint256 prescriptionId) external payable {
        ProductToken.Product memory _product = getProduct(productId);
        if (_product.NeedAuthorization) {
            // TODO: Check Prescription
            PrescriptionToken.Prescription memory _prescription = getPrescription(prescriptionId);
            require(
                _prescription.productId == productId,
                "Prescription is not valid."
            );
        }
        require(msg.value >= _product.Price, "Not enough money.");
        productToken.transferFrom(address(this), msg.sender, productId);
    }

    function sellProduct(uint256 productId, uint256 newPrice) external payable {
        ProductToken.Product memory _product = getProduct(productId);
        require(
            productToken.ownerOf(productId) == msg.sender,
            "You are not the owner"
        );
        require(
            _product.NeedAuthorization == false,
            "This product need authorization to sell"
        );
        productToken.setPrice(productId, newPrice);
        productToken.transferFrom(msg.sender, address(this), productId);
    }

    function getProduct(uint256 tokenId) public view returns (ProductToken.Product memory) {
        ProductToken.Product memory _product = productToken.get(tokenId);
        return _product;
    }

    function getPrescription(
        uint256 tokenId
    ) public view returns (PrescriptionToken.Prescription memory) {
        return prescriptionToken.get(tokenId);
    }
}
