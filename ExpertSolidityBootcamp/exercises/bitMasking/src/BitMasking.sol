// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BitMasking {
    uint16 public a;
    uint16 public b = 0xbeef;
    uint32 public c;
    uint64 public d;
    uint128 public e = 0x0000ca11ab1ebeef00000000feedbee5;

    function getSlot() external view returns (bytes32 ret) {
        assembly {
            ret := sload(0)
        }
    }

    // TODO:
    // 1. Read variable b and return its value 0xbeef

    // SOLVED:
    function readBeef() external view returns (bytes32 ret) {
        assembly {
            // Solution: shift right slot `0`, then and masking with 0xffff
            let value := sload(b.slot)
            let offset := b.offset
            let shifted := shr(mul(offset, 8), value)
            ret := and(0xffff, shifted)
        }
    }

    // TODO:
    // 1. Store 0xf00dc0de in variable c
    // 2. Store 0xc0ffee0000d15ea5 in variable d
    // Note: use yul, bit shifting and bit masking only

    // FIXME: Challenge 1
    function foodCode() external {
        assembly {
            let slot0 := sload(0)
            let cValue := 0xf00dc0de
            let dValue := 0xc0ffee0000d15ea5
            let combinedDc := or(shl(64, dValue), shl(32, cValue))
            let combined := or(slot0, combinedDc)
            sstore(0, combined)
        }
    }

    // TODO:
    // 1. Modify the first two bytes of variable e to be `0xce00`
    // 2. Put 0xfaceb00c from the 9th to 12th byte of variable e inplace

    // FIXME: Challenge 2
    function facebooc() external {
        assembly {
            let slot0 := sload(0)
            let mask := 0xffffffffffff00ffffffffffffffffffffffffffffffffffffffffffffff
            let newValue := or(shl(240, 0xce00), shl(160, 0xfaceb00c))
            let cleared := and(slot0, mask)
            let combined := or(cleared, newValue)
            sstore(0, combined)
        }
    }

    // TODO:
    // 1. For variable e, leave the byte words `beef` and `bee` inplace, discard all other non-zero bytes words
    // 2. For variable d, mask the word `fee`, add 1/2 byte `d` to `fee` so that it reads `feed`
    // 3. For variable b, mask the word `beef` that appears only once, and dicard all other packed bytes
    // NOTE: If all variable are updated correctly, slot 0 should return 0xbeef000000000000bee0000feed00000000000000000beef0000

    // FIXME: Challenge 3
    function beefBeeFeedBeef() external {
        this.foodCode();
        this.facebooc();
        assembly {
            let slot0 := sload(0)
            let eMask := 0x0000000000000ffff000000000000fff000000000000000000000000000000000
            let dMask := 0x0000000000000000000000000000000000000000000000000000000000000000
            let dValue := shl(100, 0xfeed)
            let bMask := 0x00000000000000000000000000000000000000000000000000000000ffff0000
            let maskedE := and(slot0, eMask)
            let maskedD := and(slot0, dMask)
            let maskedB := and(slot0, bMask)
            let combined := or(or(maskedE, maskedD), maskedB)
            combined := or(combined, dValue)
            sstore(0, combined)
        }
    }
}
