// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Slot is where the actual variable is (var.slot gives the location)
// sload(slot)
// sstore(slot, value)
contract YulStorageRead {
    uint256 private a;
    uint256 private x;

    function getXSlot() external pure returns (uint256 _x) {
        assembly {
            _x := x.slot
        }
    }

    function getXYul() external view returns (uint256 _x) {
        assembly {
            // _x := sload(x.slot) EQUIVALENT
            _x := sload(1)
        }
    }

    function setXYul(uint256 _newX) external {
        assembly {
            // takes the slot and the value
            sstore(1, _newX)
        }
    }
}
