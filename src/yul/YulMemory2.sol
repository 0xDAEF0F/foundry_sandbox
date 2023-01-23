// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract YulMemory2 {
    function return2And4FromMemory() external pure returns (uint256, uint256) {
        assembly {
            mstore(0x00, 2)
            mstore(0x20, 4)
            // return takes offset, size
            return(0x00, 0x40) // offset: 0 - size: 64 bytes
        }
    }

    function revertWithZeroData() external pure {
        assembly {
            // offset size
            revert(0, 0)
        }
    }

    function revertWithMessage() external pure returns (bytes32) {
        assembly {
            mstore(0x00, 0x68656c6c6f000000000000000000000000000000000000000000000000000000)
            // revert with 32 bytes as return value
            revert(0, 0x20)
        }
    }

    function hashV1() external pure returns (bytes32) {
        bytes memory toBeHashed = abi.encode(1, 2, 3);
        return keccak256(toBeHashed);
    }

    function hashV1Implicit() external pure returns (bytes32) {
        // we implicitly have the encoding in memory
        return keccak256(abi.encode(1, 2, 3));
    }

    function hashV1Yul() external pure returns (bytes32) {
        assembly {
            let fmp := mload(0x40)

            // store 1, 2, 3 in memory
            mstore(fmp, 1)
            mstore(add(fmp, 0x20), 2)
            mstore(add(fmp, 0x40), 3)

            // update free memory pointer
            mstore(0x40, add(fmp, 0x60)) // increase by 96 bytes

            // you store in the first word of the scratch space
            // the following 96 bytes of the free memory pointer
            mstore(0x00, keccak256(fmp, 0x60)) // in this case you are feeding into keccak256 96 bytes
            // return the first 32 bytes from memory
            // keccak256 :: bytes -> bytes32
            return(0x00, 0x20)
        }
    }
}
