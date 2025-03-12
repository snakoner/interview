// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/Clones.sol";

contract CloneFactory {
    using Clones for address;    
    
    address public implementation;
    address[] public proxies;

    event CloneCreated(address indexed cloneAddress);

    constructor(address _impl) {
        implementation = _impl;
    }

    function createClone() external returns (address) {
        address clone = implementation.clone();
        proxies.push(clone);

        emit CloneCreated(clone);

        return clone;
    }

    function getProxiesNumber() external view returns (uint256) {
        return proxies.length;
    }
}
