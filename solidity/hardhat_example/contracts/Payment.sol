// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

contract Payments {
    struct Payment {
        uint amount;
        uint timestamp;
        address from;
        string message;
    }

    struct Balance {
        uint totalPayments;
        mapping(uint => Payment) payments;
    }

    mapping (address => Balance) public balances;


    function getPayment(address _addr, uint _index) public view returns (Payment memory) {
        return balances[_addr].payments[_index];
    } 

    function currentBalance() public view returns(uint) {
        return address(this).balance;
    }

    function balanceOf(address _address) public view returns (uint) {
        uint balance = 0;
        uint totalPayments = balances[_address].totalPayments;

        for (uint i = 0; i < totalPayments; i++) {
            balance += balances[_address].payments[i].amount;
        }

        return balance;
    }

    function pay(string memory message) public payable {
        uint totalPayments = balances[msg.sender].totalPayments;

        Payment memory payment = Payment(
            msg.value,
            block.timestamp,
            msg.sender,
            message
        );


        balances[msg.sender].payments[totalPayments] = payment;
        balances[msg.sender].totalPayments++;
    }
}
