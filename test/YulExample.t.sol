// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {YulExample} from "../src/YulExample.sol";

contract YulExampleTest is Test {
    YulExample public yulExample;

    function setUp() public {
        yulExample = new YulExample();
    }

    function testWhatIsTheMeaningOfLife() public {}
}
