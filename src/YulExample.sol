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

    // returns an address 0x000...1
    function whatIsTheMeaningOfLifeC() external pure returns (address a) {
        assembly {
            a := 0x1
        }
    }

    function isPrime(uint256 x) public pure returns (bool p) {
        p = true;
        assembly {
            // declare new variable
            let halfX := add(div(x, 2), 1)
            for { let i := 2 } lt(i, halfX) { i := add(i, 1) } {
                // ^Ini        ^Condition   ^Afterthought
                // OPTIONAL    NECESSARY    OPTIONAL
                // OPTIONAL BLOCKS NEED THE BRACKETS TO COMPILE
                if iszero(mod(x, i)) {
                    p := 0
                    break
                }
            }
        }
    }

    // 0 evaluates to false the result to true
    function isTruthy(uint256 _val) external pure returns (bool result) {
        assembly {
            if _val { result := 1 }
        }
    }

    function negation(uint256 _num) external pure returns (uint256 result) {
        assembly {
            result := 1
            if iszero(_num) { result := 2 }
        }
    }

    function bitFlip(uint256 _value) external pure returns (bytes32 result) {
        assembly {
            result := not(_value)
        }
    }

    function max(uint256 x, uint256 y) external pure returns (uint256 _max) {
        assembly {
            _max := x
            if lt(x, y) { _max := y }
        }
    }
}
