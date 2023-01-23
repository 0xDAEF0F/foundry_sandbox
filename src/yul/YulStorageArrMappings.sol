// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract YulStorageArrMappings {
    uint256[3] private fixedArr;
    uint256[] private dynamicArr;

    mapping(uint256 => uint256) public myMapping;
    mapping(uint256 => mapping(uint256 => uint256)) public myNestedMapping;

    constructor() {
        fixedArr = [99, 999, 9999];
        dynamicArr = [8, 88, 888, 8888];
        // normal mapping
        myMapping[9] = 9;
        myMapping[99] = 99;
        myMapping[999] = 999;
        myMapping[9999] = 9999;
        // nested mapping
        myNestedMapping[9][9] = 9;
        myNestedMapping[99][99] = 99;
        myNestedMapping[999][999] = 999;
    }

    function getValueBySlot(uint256 _slot) external view returns (uint256 _val) {
        assembly {
            _val := sload(_slot)
        }
    }

    // for fixed length arrays the it's slot is the first element in the array
    function getFixedArrayValueYul(uint256 _idx) external view returns (uint256 _val) {
        assembly {
            let storagePositionOfIndex := add(fixedArr.slot, _idx)
            _val := sload(storagePositionOfIndex)
        }
    }

    function getValueByIndexOfDynamicArrInYul(uint256 _idx) external view returns (uint256 _val) {
        uint256 slot;
        assembly {
            slot := dynamicArr.slot
        }
        bytes32 location = keccak256(abi.encode(slot));
        assembly {
            _val := sload(add(location, _idx))
        }
    }

    // the slot in a dynamic array contains the number of items in the array
    function getLengthDynamicArr() external view returns (uint256 _ret) {
        assembly {
            _ret := sload(dynamicArr.slot)
        }
    }

    // To read a storage variable from a mapping, you abi encode the key + slot and hash it
    // and that gives you the location in storage of the key you are looking for
    function getValueNormalMappingInYul(uint256 _idx) external view returns (uint256 _val) {
        uint256 myMappingSlot;
        assembly {
            myMappingSlot := myMapping.slot
        }
        bytes32 location = keccak256(abi.encode(_idx, myMappingSlot));
        assembly {
            _val := sload(location)
        }
    }

    // for nested mappings you just apply the same rule recursively
    function getValueNestedMappingInYul(uint256 _keyOne, uint256 _keyTwo) external view returns (uint256 _val) {
        uint256 slot;
        assembly {
            slot := myNestedMapping.slot
        }
        bytes32 firstLocation = keccak256(abi.encode(uint256(_keyOne), slot));
        bytes32 valueLocation = keccak256(abi.encode(uint256(_keyTwo), firstLocation));
        assembly {
            _val := sload(valueLocation)
        }
    }
}
