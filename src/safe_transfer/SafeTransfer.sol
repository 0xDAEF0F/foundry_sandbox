// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract SafeTransferExample {
    using SafeTransferLib for ERC20;

    ERC20 private immutable token;

    constructor(address _tokenAddr) {
        token = ERC20(_tokenAddr);
    }

    function unsafeGetTokensFrom(address _addr, uint256 _amount) external returns (bool) {
        token.safeTransferFrom(_addr, address(this), _amount);
        return true;
    }

    function safeGetTokensFrom(address _addr, uint256 _amount) external returns (bool) {
        require(address(token).code.length > 0, "NO_CODE");
        token.safeTransferFrom(_addr, address(this), _amount);
        return true;
    }
}
