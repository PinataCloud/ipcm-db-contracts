// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {IPCM} from "../src/IPCM.sol";

contract IPCMTest is Test {
    IPCM public ipcm;
    address owner = address(0); // Changed from address(1) to address(0)
    address editor = address(2);
    address nonEditor = address(4);
    string testCid = "QmTest123";
    bytes32 public constant EDITOR_ROLE = keccak256("EDITOR_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    function setUp() public {
        vm.startPrank(owner);
        ipcm = new IPCM();
        vm.stopPrank();
    }

    function testSetValue() public {
        vm.startPrank(owner);
        ipcm.updateMapping(testCid);
        assertEq(ipcm.getMapping(), testCid);
        vm.stopPrank();
    }

    function testOnlyEditorCanSetValue() public {
        vm.startPrank(nonEditor);
        vm.expectRevert();
        ipcm.updateMapping(testCid);
        vm.stopPrank();
    }

    function testEditorRoleCanUpdateMapping() public {
        // Grant editor role to the editor address
        vm.startPrank(owner);
        ipcm.grantRole(EDITOR_ROLE, editor);
        vm.stopPrank();

        // Editor updates the mapping
        vm.startPrank(editor);
        ipcm.updateMapping(testCid);
        assertEq(ipcm.getMapping(), testCid);
        vm.stopPrank();
    }

    function testOnlyDefaultAdminCanGrantRoles() public {
        // Owner (who has DEFAULT_ADMIN_ROLE) grants editor role to nonEditor
        vm.startPrank(owner);
        ipcm.grantRole(EDITOR_ROLE, nonEditor);
        vm.stopPrank();

        // Now nonEditor should be able to update mapping
        vm.startPrank(nonEditor);
        ipcm.updateMapping(testCid);
        assertEq(ipcm.getMapping(), testCid);
        vm.stopPrank();
    }

    function testNonAdminCannotGrantRoles() public {
        // Grant editor role to editor
        vm.startPrank(owner);
        ipcm.grantRole(EDITOR_ROLE, editor);
        vm.stopPrank();

        // Editor tries to grant editor role to nonEditor but fails
        vm.startPrank(editor);
        vm.expectRevert();
        ipcm.grantRole(EDITOR_ROLE, nonEditor);
        vm.stopPrank();
    }

    function testEmitsEvent() public {
        vm.startPrank(owner);
        vm.expectEmit(true, true, true, true);
        emit IPCM.MappingUpdated(testCid);
        ipcm.updateMapping(testCid);
        vm.stopPrank();
    }

    function testGetValue() public {
        vm.startPrank(owner);
        ipcm.updateMapping(testCid);
        string memory initialValue = ipcm.getMapping();
        assertEq(initialValue, testCid);

        string memory newTestCid = "QmTest456";
        ipcm.updateMapping(newTestCid);
        string memory newValue = ipcm.getMapping();
        assertEq(newValue, newTestCid);
        vm.stopPrank();
    }
}
