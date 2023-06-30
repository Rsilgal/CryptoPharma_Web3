// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract ProductToken is
    ERC721,
    ERC721Enumerable,
    Pausable,
    AccessControl,
    ERC721Burnable
{
    using Counters for Counters.Counter;

    struct Product {
        bytes32 Name;
        bytes32 Desctiption;
        bytes32 Lot;
        uint256 Quantity;
        uint256 ExpireDate;
        uint256 Price;
        bool PharmaService;
        bool HospitalService;
        bool NeedAuthorization;
    }
    
    mapping (uint => Product) products;

    Counters.Counter private _tokenIdCounter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC721("ProductToken", "MTK") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    modifier _checkIfItExist(uint256 tokenId) {
        require(_exists(tokenId), "Not exist a token with this Id");
        _;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // TODO: Add payable funtion
    function safeMint(
        bytes32 _productName,
        bytes32 _productDescription,
        bytes32 _productLot,
        bool _productPharmaService,
        bool _productHospitalService,
        bool _productAuthorization,
        uint256 _productQuantity,
        uint256 _productExpireDate,
        uint _productPrice
    ) public onlyRole(MINTER_ROLE) {
        //TODO: Check if there another product with the same data
        uint256 tokenId = _tokenIdCounter.current();
        products[tokenId] = Product(_productName, _productDescription, _productLot, _productQuantity, _productExpireDate, _productPrice, _productPharmaService, _productHospitalService, _productAuthorization);
        _tokenIdCounter.increment();
        _mint(msg.sender, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function grantRoleMinter(
        address account
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, account);
        // TODO: Emit an event
    }

    function grantRoleAdmin(
        address account
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(DEFAULT_ADMIN_ROLE, account);
        //TODO: Emit an event
    }

    function _get(uint256 tokenId) internal view _checkIfItExist(tokenId) returns (Product memory) {
        return products[tokenId];
    }

    function get(uint256 tokenId) external view returns (Product memory) {
        return _get(tokenId);
    }

    function setPrice(uint256 tokenId, uint256 newPrice) _checkIfItExist(tokenId) external {
        products[tokenId].Price = newPrice;
    }
}
