// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract PrescriptionToken is
    ERC721,
    ERC721Enumerable,
    Pausable,
    AccessControl,
    ERC721Burnable
{
    using Counters for Counters.Counter;

    struct Prescription {
        uint256 productId;
        uint256 amountToTake;
        uint256 coolDownHours;
        uint256 productQuantity;
        address to;
    }

    mapping (uint => Prescription) prescriptions;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("PrescriptionToken", "MTK") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    modifier _checkIfItExist(uint256 tokenId) {
        require(_exists(tokenId), "Not exist a token with this Id");
        _;
    }

    modifier _hasPermision(uint256 tokenId){
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || ownerOf(tokeId) === msg.sender, "Can't read this prescription");
        _;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(
        address to,
        uint256 _productId,
        uint256 _amountToTake,
        uint256 _coolDownHours,
        uint256 _productQuantity
    ) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        prescriptions[tokenId] = new Prescription(_productId, _amountToTake, _coolDownHours, _productQuantity, to)
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
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

    function _get(uint256 tokenId) internal view _checkIfItExist(tokenId) _hasPermision(tokeId) returns (Prescription){
        return prescriptions[tokenId];
    }

    function get(uint256 tokenId) external view {
        return _get(uint256 tokenId);
    }
}
