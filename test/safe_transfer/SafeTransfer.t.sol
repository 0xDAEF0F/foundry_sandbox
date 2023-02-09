// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {SafeTransferExample} from "src/safe_transfer/SafeTransfer.sol";

contract SafeTransferExampleTest is Test {
    SafeTransferExample public example;
    address public nonExistentERC20 = makeAddr("non_existent");

    function setUp() public {
        example = new SafeTransferExample(nonExistentERC20);
    }

    function testCallToNonExistentContractIsTrue() public {
        bool success = example.unsafeGetTokensFrom(makeAddr("bob"), 1);
        assertEq(success, true);
    }

    function testCallToNonExistentContractReverts() public {
        vm.expectRevert("NO_CODE");
        example.safeGetTokensFrom(makeAddr("bob"), 1);
    }
}
