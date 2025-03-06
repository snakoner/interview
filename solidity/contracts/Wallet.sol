
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Wallet is Ownable {
    error WalletNullInputAmount();
    error WalletInsufficientBalance();
    error TransferFailed();

    event TokenSend(address indexed token, address indexed to, uint256 amount);
    event EthSend(address indexed to, uint256 amount);

    constructor() Ownable(msg.sender) {}

    // for receiving ETH
    receive() external payable{}

    function balanceOfERC20(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function sendERC20(
        address token, 
        address to, 
        uint256 amount
    ) external onlyOwner {
        require(amount != 0, WalletNullInputAmount());
        uint256 balance = balanceOfERC20(token);

        require(balance >= amount, WalletInsufficientBalance());
        require(IERC20(token).transfer(to, amount), TransferFailed());

        emit TokenSend(token, to, amount);
    }

    function sendETH(address to, uint256 amount) external onlyOwner {
        require(amount != 0, WalletNullInputAmount());
        uint256 balance = address(this).balance;

        require(balance >= amount, WalletInsufficientBalance());

        (bool success, ) = to.call{value: amount}("");
        require(success, TransferFailed());

        emit EthSend(to, amount);
    }
}
