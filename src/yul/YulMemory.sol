// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Since objects in memory are laid out end to end, arrays have
// no push method like storage does.
// to access dynamic arrays in memory you need to skip the first
// 32 bytes because that is where the length is
// NOTE: If you do not respect the free memory pointer (0x40)
// and the memory layout. SERIOUS bugs can occur
contract YulMemory {
    struct Point {
        uint256 x;
        uint256 y;
    }

    event MemoryPointer(bytes32);
    event MemoryPointerMSize(bytes32, bytes32);
    event Debug(bytes32, bytes32, bytes32, bytes32);
    // mstore: stores a word in memory
    // mstore8: stores a byte in memory
    // mload: loads a word from memory
    // the higher up you use memory the more it will cost you

    uint256[3] public fixedArr;

    constructor() {
        fixedArr = [9, 99, 999];
    }

    function highAccess() external pure {
        // the mload of that memory location
        // will cost more than the 3 million gas limit
        // and the transaction will revert with run out of gas
        assembly {
            // pop throws away the value
            pop(mload(0xffffffffffffffff))
        }
    }

    // NOTE: debug this transaction to see the memory changing
    function mstore8() external pure {
        assembly {
            // this will save a byte to memory in offset 0
            mstore8(0x00, 7)
            // this will save a word to memory at offset 0
            mstore(0x00, 7)
        }
    }

    function memPointer() external {
        bytes32 x40;
        assembly {
            // this will a word from the free memory pointer
            // and assign it to the variable x40
            x40 := mload(0x40)
        }
        // current allocated memory: 128 bytes
        emit MemoryPointer(x40);
        Point memory p = Point({x: 1, y: 2});
        assembly {
            x40 := mload(0x40)
        }
        // after the allocation of the struct: 192 bytes
        emit MemoryPointer(x40);
        // 192 - 128 = 64 bytes
        // since the struct contains two words of 32 bytes
    }

    function memPointerV2() external {
        bytes32 x40;
        bytes32 _msize;
        assembly {
            x40 := mload(0x40)
            _msize := msize()
        }
        emit MemoryPointerMSize(x40, _msize);
        Point memory p = Point({x: 1, y: 2});
        assembly {
            x40 := mload(0x40)
            _msize := msize()
        }
        emit MemoryPointerMSize(x40, _msize);

        assembly {
            // reading from location 0xff and discarding the value
            pop(mload(0xff))
            // we load the free memory pointer (should not have changed)
            x40 := mload(0x40)
            // we load the msize which has changed because we read from 0xff
            _msize := msize()
        }
        emit MemoryPointerMSize(x40, _msize);
    }

    function fixedArray() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        // 0x80
        emit MemoryPointer(x40);
        uint256[3] memory copyArr = fixedArr;
        assembly {
            x40 := mload(0x40)
        }
        // 0xe0
        emit MemoryPointer(x40);
        // difference amounts to 96 bytes = 256 * 3 / 8
    }

    // the output of abi.encode either goes into storage or memory
    function abiEncode() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        // 0x80 at first
        emit MemoryPointer(x40);
        bytes memory encode = abi.encode(uint256(5), uint256(19));
        assembly {
            x40 := mload(0x40)
        }
        // 0xe0 after the encoding
        // means the encoding occupied 96 bytes in memory
        // 32 bytes for the length of the encoding
        // 64 bytes for the contents
        emit MemoryPointer(x40);
    }

    function abiEncode2() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        // 0x80
        emit MemoryPointer(x40);
        // when you encode a set of values, solidity will encode them
        // as 32 byte words even if they are shorter
        abi.encode(uint256(1), uint128(2));
        abi.encode(uint256(1), uint256(2));
        abi.encode(uint8(1), uint8(2));
        // all of these bytes will be equal
        assembly {
            x40 := mload(0x40)
        }
        // 0x1a0
        // 0x1a0 - 0x80 = 288 bytes = 96 bytes * 3 = 32 bytes * 3 words * 3 encodings
        emit MemoryPointer(x40);
    }

    function abiEncodePacked() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        // 0x80
        emit MemoryPointer(x40);
        abi.encodePacked(uint8(1), uint8(2));
        assembly {
            x40 := mload(0x40)
        }
        // 0xa2 = 32 bytes for the length and 2 bytes for the contents
        emit MemoryPointer(x40);
    }

    function args(uint256[] memory arr) external {
        bytes32 location;
        bytes32 len;
        bytes32 valueAt0;
        bytes32 valueAt1;

        assembly {
            // if you reference the arr variable itself it will give you
            // the position of where it is located in memory
            location := arr
            len := mload(arr)
            valueAt0 := mload(add(arr, 0x20))
            valueAt1 := mload(add(arr, 0x40))
        }
        emit Debug(location, len, valueAt0, valueAt1);
    }

    function breakFreeMemoryPointer(uint256[1] memory foo) external pure returns (uint256) {
        assembly {
            // we are changing the FMP to where it was before
            // the foo array was allocated
            mstore(0x40, 0x80)
        }
        // this value gets saved at offset 0x80:0xa0
        uint256[1] memory bar = [uint256(6)];
        return foo[0];
    }
}
