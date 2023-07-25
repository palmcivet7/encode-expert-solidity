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
        uint256 length = array.length;
        if (index >= length) {
            revert Homework2__InvalidNumber();
        }
        uint256 i = index;
        unchecked {
            while (i < length - 1) {
                array[i] = array[i + 1];
                ++i;
            }
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
