// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Refer here for variable argument calldata information
// https://docs.soliditylang.org/en/v0.8.17/abi-spec.html#examples
contract YulVariableLength {
    struct Example {
        uint256 a;
        uint256 b;
        uint256 c;
    }

    function threeArgs(uint256 a, uint256[] calldata b, uint256 c) external {}

    function threeArgsStruct(uint256 a, Example calldata b, uint256 c) external {}

    function fiveArgs(uint256 a, uint256[] calldata b, uint256 c, uint256[] calldata d, uint256 e) external {}

    function oneArg(uint256[] calldata a) external {}

    function allVariable(uint256[] calldata a, uint256[] calldata b, uint256[] calldata c) external {}
}
