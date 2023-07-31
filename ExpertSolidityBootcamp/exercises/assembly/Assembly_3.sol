pragma solidity ^0.8.4;

contract SubOverflow {
    // Modify this function so that on overflow it returns the value 0
    // otherwise it should return x - y
    function subtract(uint256 x, uint256 y) public pure returns (uint256) {
        // Write assembly code that handles overflows
        assembly {
            switch lt(x, y)
            case 0 {
                // if x is not less than y (x >= y)
                let result := sub(x, y)
                mstore(0x40, result) // store result in memory
            }
            default {
                // if x is less than y (x < y)
                mstore(0x40, 0) // store 0 in memory
            }
            let ptr := mload(0x40) // load free memory pointer
            return(ptr, 32) // return result or 0 from memory
        }
    }
}
