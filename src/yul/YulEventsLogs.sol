// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Topic 0 -> keccak256 of the event signature
// Topic 1 -> 5
// Topic 2 -> 6
contract YulEventsLogs {
    event SomeLog(uint256 indexed a, uint256 indexed b);
    event SomeLog2(uint256 indexed a, bool);

    function emitLog() external {
        emit SomeLog(5, 6);
    }

    function yulEmitLog() external {
        assembly {
            let fmp := mload(0x40)
            // store after fmp this bytes
            mstore(fmp, "SomeLog(uint256,uint256)")
            // increase the length of the fmp by 32 bytes
            mstore(0x40, add(fmp, 0x20))
            // hash from fmp + 32 bytes and store in 0x00
            mstore(0x00, keccak256(fmp, 0x18))
            // emit the event
            log3(0, 0, mload(0x00), 5, 6)
        }
    }

    function hashEventSignature() external pure returns (bytes32) {
        assembly {
            let fmp := mload(0x40)
            mstore(fmp, "SomeLog(uint256,uint256)")
            mstore(0x40, add(fmp, 0x20))

            mstore(0x00, keccak256(fmp, 0x18)) // only hash the bytes which are 24 bytes OR 0x18
            return(0x00, 0x20)
        }
    }

    function returnEventSignatureInBytes32() external pure returns (bytes32) {
        assembly {
            // will be casted to bytes
            mstore(0x00, "SomeLog(uint256,uint256)")
            return(0x00, 0x20)
        }
    }

    function v2EmitLog() external {
        emit SomeLog2(5, true);
    }

    function v2YulEmitLog() external {
        assembly {
            // keccak256("SomeLog2(uint256,bool)")
            let signature := 0xaefa010f939214fae1e59fb086529644424f237026307231d77d0d2405f03a5d
            // store 1 in first word memory
            mstore(0x00, 1)
            // whatever you put will be indexed
            log2(0, 0x20, signature, 5)
            // NOTE: non indexed arguments will be retrieved from memory
            // in this case there is just one and that is why you need the
            // boundaries in the first two arguments
        }
    }
}
