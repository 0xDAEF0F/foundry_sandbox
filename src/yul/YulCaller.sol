// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// - tx.data can have arbitrary length. it is ONLY constrained by gas cost.
// - first four bytes in tx.data represent function signature (bytes4(keccak256("sig()")))
// - solidity will expect bytes after fn selector to always be 32 bytes (word)
// - With Yul a contract can respond to arbitrary length tx.data programatically
// - external web libraries know how to call contracts because of the ABI
// - When using interface in solidity it transforming the signature and arguments for you.
// - In Yul you have to explicitly do this.
// - Staticcall guarantees that you are not modifying state as opposed to call
contract YulCaller {
    function externalViewCallNoArgs(address _a) external view returns (uint256) {
        assembly {
            // keccak of "get21()"
            mstore(0, 0x9a884bde)
            // args: gas, address, argsOffset, argsSize, retOffset, retSize
            let success := staticcall(gas(), _a, 28, 32, 0, 32)
            if iszero(success) { revert(0, 0) }
            return(0, 32)
        }
    }

    function getViaRevert(address _a) external view returns (uint256) {
        assembly {
            mstore(0, 0x73712595)
            // since it will revert it will have a zero as return data
            // and we remove it to get the data (999)
            pop(staticcall(gas(), _a, 28, 32, 0, 32))
            // either if the function reverts or succeeds it is going to be
            // written to the area you preallocated (in this case 0)
            return(0, 32)
        }
    }

    function callMultiply(address _a) external view returns (uint256 result) {
        assembly {
            mstore(0x80, 0x196e6d84) // keccak of "multiply()"
            // one word after the memory pointer store 3
            mstore(0xa0, 3)
            // followed by 11
            mstore(0xc0, 11)
            // advance the memory pointer by 3 x 32 bytes
            mstore(0x40, add(0x80, 0x60))
            // now make the call
            let success := staticcall(gas(), _a, add(0x80, 28), 96, 0, 32)
            if iszero(success) { revert(0, 0) }

            result := mload(0)
        }
    }

    function callMultiply2(address _a) external view returns (uint256 _res) {
        assembly {
            // store selector in 0x80
            mstore(0x80, 0x196e6d84)
            mstore(0xa0, 3)
            mstore(0xc0, 11)
            // then update the free memory pointer because you have just wrote 96 bytes to memory
            mstore(0x40, add(0x80, 0x60))
            // make the call
            let success := staticcall(gas(), _a, add(0x80, 28), 96, 0, 32)
            // 1. forward gas
            // 2. address to call to
            // 3. what is the byte offset in the memory (context)
            // 4. what is the size of the argument in bytes
            // 5. where should the return value be written
            // 6. return size of the data

            if iszero(success) { revert(0, 0) } // if sucess is zero just revert with nothing

            // else return the first word in memory
            // that is where the value was saved, remember?
            _res := mload(0)
        }
    }

    // if the function was payable we could forward the value by doing callvalue()
    // in the third argument of call
    function externalStateChangingCall(address _a) external {
        assembly {
            // first set the selector
            mstore(0x80, 0x4018d9aa)
            mstore(add(0x80, 0x20), 0xff) // 255 new value

            let success := call(gas(), _a, 0x00, add(0x80, 28), 64, 0, 0)

            if iszero(success) { revert(0, 0) }
        }
    }

    function unknownReturnSize(address _a, uint256 _amount) external view returns (bytes memory) {
        assembly {
            mstore(0, 0x7c70b4db) // selector for variableReturnLength(uint256)
            mstore(32, _amount)

            let success := staticcall(gas(), _a, 28, 64, 0, 0)
            // since you do not know the return size
            // leave return offset to 0
            // and return size to 0
            if iszero(success) { revert(0, 0) }

            // get byte size return data
            let returnSize := returndatasize()

            // destOffset, offset, size
            returndatacopy(0, 0, returnSize)

            return(0, returnSize)
        }
    }

    function externalAreListsEqual(address _a) external view returns (bool) {
        // lists we are trying: [1,2], [1,2]
        assembly {
            // selector for: "isEqualArrays(uint256[],uint256[])"
            mstore(0x80, 0x7619178c)
            mstore(0xa0, 64)
            mstore(0xc0, 160)

            mstore(0xe0, 2) // length first array
            mstore(0x100, 1) // first value
            mstore(0x120, 2) // snd value

            mstore(0x140, 2) // length second array
            mstore(0x160, 1) // first value
            mstore(0x180, 2) // snd value

            mstore(0x40, add(0x80, mul(32, 9))) // update memory pointer

            let success := staticcall(gas(), _a, add(0x80, 28), mul(32, 9), 0, 32)
            if iszero(success) { revert(0, 0) }
            // return from slot 0
            return(0, 32)
        }
    }
}
