// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract ProductToken is
    ERC1155,
    AccessControl,
    Pausable,
    ERC1155Burnable,
    ERC1155Supply,
    ReentrancyGuard
{
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using Counters for Counters.Counter;

    struct Product {
        string Name;
        string Desctiption;
        string Lot;
        uint256 Quantity;
        uint256 ExpireDate;
        uint256 Price;
        bool PharmaService;
        bool HospitalService;
        bool NeedAuthorization;
    }

    mapping(uint => Product) products;

    Counters.Counter private _tokenIdCounter;

    event productMinted();

    constructor() ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(
        address _account,
        uint256 _amount,
        Product memory _data
    ) public onlyRole(MINTER_ROLE) nonReentrant()
    {
        uint256 _id = _tokenIdCounter.current();
        _mint(_account, _id, _amount, "");
        products[_id] = _data;
        _tokenIdCounter.increment();
        emit productMinted();
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function getData(uint256 _id) external view returns (Product memory _p) {
        require(
            exists(_id),
            "Looks like you request data from non-existent token"
        );
        _p = products[_id];
    }

    function defineApproved(address approvedAccount) onlyRole(DEFAULT_ADMIN_ROLE) public nonReentrant {
        setApprovalForAll(approvedAccount, true);
    }

    function revokeApproved(address account) onlyRole(DEFAULT_ADMIN_ROLE) public nonReentrant {
        setApprovalForAll(account, false);
    }
}
