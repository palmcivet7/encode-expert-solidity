pragma solidity ^0.8.4;

contract Scope {
    uint256 public count = 10;

    function increment(uint256 num) public {
        // Modify state of the count variable from within
        // the assembly segment
        assembly {
            let tmp := add(sload(count.slot), num) // increment count by num
            sstore(count.slot, tmp) // store the new value back in the count slot
        }
    }
}
