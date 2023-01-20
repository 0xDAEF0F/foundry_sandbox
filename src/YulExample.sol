// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// NOTE:
// := is how you set variables in yul
// Each word in yul is plain bytes32 type
// solidity will cast return type based on function signature

contract YulExample {
    // return 1
    function whatIsTheMeaningOfLifeA() external pure returns (uint256 a) {
        assembly {
            a := 0x1
        }
    }

    // return true
    function whatIsTheMeaningOfLifeB() external pure returns (bool a) {
        assembly {
            a := 0x1
        }
    }
}
