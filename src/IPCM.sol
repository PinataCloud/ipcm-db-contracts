// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.23;

import {AccessControl} from "dependencies/@openzeppelin-contracts-5.3.0-rc.0/access/AccessControl.sol";

contract IPCM is AccessControl {
    string private cidMapping;

    bytes32 public constant EDITOR_ROLE = keccak256("EDITOR_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(EDITOR_ROLE, msg.sender);
    }

    event MappingUpdated(string value);

    function updateMapping(string memory value) public onlyRole(EDITOR_ROLE) {
        cidMapping = value;
        emit MappingUpdated(value);
    }

    function getMapping() public view returns (string memory) {
        return cidMapping;
    }
}
