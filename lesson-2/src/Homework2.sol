// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Homework2 {
    error Homework2__InvalidNumber();

    uint256[] private array;

    constructor() {
        array = new uint256[](12);
        for (uint256 i = 0; i < 12; i++) {
            array[i] = i;
        }
    }

    function removeIndex(uint256 index) public {
        if (index >= array.length) {
            revert Homework2__InvalidNumber();
        }
        for (uint256 i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }
        array.pop();
    }

    function getArrayLength() public view returns (uint256) {
        return array.length;
    }

    function getArray() public view returns (uint256[] memory) {
        return array;
    }
}
