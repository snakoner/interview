// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract Logic {
    uint256 private _value;

    function setValue(uint256 newValue) external {
        _value = newValue;
    }
}