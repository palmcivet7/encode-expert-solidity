// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployHomework2} from "../../script/DeployHomework2.s.sol";
import {Homework2} from "../../src/Homework2.sol";

contract TestHomework2 is Test {
    Homework2 homework;

    address public USER = makeAddr("USER");
    uint256[] testArray = [0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11];

    function setUp() external {
        DeployHomework2 deployer = new DeployHomework2();
        (homework) = deployer.run();
    }

    function testConstructor() public {
        assertEq(homework.getArrayLength(), 12);
    }

    function testRemoveIndexRevertsWithInvalidNumber() public {
        vm.startPrank(USER);
        vm.expectRevert(Homework2.Homework2__InvalidNumber.selector);
        homework.removeIndex(12);
        vm.stopPrank();
    }

    function testRemoveIndex() public {
        vm.startPrank(USER);
        homework.removeIndex(7);
        assertEq(homework.getArray(), testArray);
        vm.stopPrank();
    }
}
