// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import '../node_modules/@openzeppelin/contracts/access/AccessControl.sol';
import '../node_modules/@openzeppelin/contracts/security/Pausable.sol';

contract Controller is AccessControl, Pausable{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpaused() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}