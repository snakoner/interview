// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Weth is ERC20 {
    event Deposit(address indexed from, uint amount);
    event Withdraw(address indexed to, uint amount);

    constructor() ERC20("Wrapped ETH", "WETH") {}

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    receive() external payable {
        deposit();
    }

    fallback() external payable {
        deposit();
    }

    function deposit() public payable {
        uint amount = msg.value;

        _mint(msg.sender, amount);

        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint amount) public payable {
        _burn(msg.sender, amount);

        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount);
    }
}
