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
        uint256 _productExpireDate
    ) public onlyMiner {
        productToken.safeMint(
            _productName,
            _productDescription,
            _productLot,
            _productPharmaService,
            _productHospitalService,
            _productAuthorization,
            _productQuantity,
            _productExpireDate
        );
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
    }

    
}
