// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract YulCallee {
    // "0c55699c": "x()"
    uint256 public x;

    // "71e5ee5f": "arr(uint256)"
    uint256[] public arr;

    // "9a884bde": "get21()"
    function get21() external pure returns (uint256) {
        return 21;
    }

    // "73712595": "revertWith999()"
    function revertWith999() external pure returns (uint256) {
        assembly {
            mstore(0, 999)
            return(0, 0x20)
        }
    }

    // "0x196e6d84": "multiply()"
    function multiply(uint128 _x, uint16 _y) external pure returns (uint256) {
        return _x * _y;
    }

    // "0x4018d9aa": "setX()"
    function setX(uint256 _x) external {
        assembly {
            sstore(x.slot, _x)
        }
    }

    // "7c70b4db": "variableReturnLength(uint256)"
    function variableReturnLength(uint256 len) external pure returns (bytes memory) {
        bytes memory ret = new bytes(len);
        for (uint256 i = 0; i < ret.length; i++) {
            ret[i] = 0xab;
        }
        return ret;
    }

    // "7619178c": "isEqualArrays(uint256[],uint256[])"
    function isEqualArrays(uint256[] calldata data1, uint256[] calldata data2) external pure returns (bool) {
        require(data1.length == data2.length, "invalid length");

        for (uint256 i = 0; i < data1.length; i++) {
            if (data1[i] != data2[i]) return false;
        }

        return true;
    }
}
