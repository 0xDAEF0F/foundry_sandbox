// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// - Storage offsetting and bitshifting
// This is necessary when multiple storage variables are packed into
// a single slot and you want to read/write to one in Yul without
// ruining the contents.
// - {Yul} .offset provides the bytes offset (to the left) of the value you
// are looking for in the word.
contract YulStorage_2 {
    uint128 c = 4;
    uint96 d = 6;
    uint16 public e = 8;
    uint8 f = 11;
    uint8 g = 10;

    // this will read from any storage slot and return the bytes32 value
    // regardless if many variables are packed into a single slot
    function readBySlot(uint256 _slot) external view returns (bytes32 value) {
        assembly {
            value := sload(_slot)
        }
    }

    function getSlotOffsetE() external pure returns (uint256 s, uint256 o) {
        assembly {
            s := e.slot
            o := e.offset
        }
    }

    function getEValue() external view returns (bytes32 _e) {
        assembly {
            // 1. load the slot from the variable you want
            let packedStorageValue := sload(e.slot)
            // 2. shift to the right by the bits offset of the variable
            // NOTE: need to multiply the offset by 8 because shr takes the bits
            // and e.offset gives the offset in bytes
            let shiftedStorageValue := shr(mul(e.offset, 8), packedStorageValue)
            // 3. do an AND bitwise operation with the value to clear the rest of the values
            // NOTE: same as 0xFF since it will get padded with zeros
            _e := and(shiftedStorageValue, 0x00000000000000000000000000000000000000000000000000000000000000FF)
        }
    }

    function writeToE(uint16 _newE) external {
        assembly {
            // this is the storage slot of e (with more values)
            let oldE := sload(e.slot)
            // storage slot 0 with e erased
            let clearedE := and(oldE, 0xffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            // will need to shift to the left the _newE and OR it with clearedE
            let shiftedNewE := shl(mul(e.offset, 8), _newE)
            let withNewE := or(shiftedNewE, clearedE)
            // store the new value
            sstore(e.slot, withNewE)
        }
    }
}
