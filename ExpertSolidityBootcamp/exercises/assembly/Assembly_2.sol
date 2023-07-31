pragma solidity ^0.8.4;

contract Add {
    function addAssembly(uint256 x, uint256 y) public pure returns (uint256) {
        // Intermediate variables can't communicate between assembly blocks
        // But they can be written to memory in one block
        // and retrieved in another.
        // Fix this code using memory to store the result between the blocks
        // and return the result from the second block
        assembly {
            let result := add(x, y)
            let ptr := mload(0x40) // load free memory pointer
            mstore(ptr, result) // store result in memory
            mstore(0x40, add(ptr, 32)) // update free memory pointer
        }

        assembly {
            let ptr := sub(mload(0x40), 32) // get the memory address of the result
            return(ptr, 32)
        }
    }
}
