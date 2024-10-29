// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract MultisigWallet {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner, 
        uint indexed index, 
        address indexed to, 
        uint value, 
        bytes data
    );

    event ConfirmTransaction(address indexed owner, uint index);
    event RevokeConfirmation(address indexed owner, uint index);
    event ExecuteTransaction(address indexed owner, uint index);


    struct Transaction {
        address to;
        bool executed;
        uint confirmations;
        uint value;
        bytes data;
    }

    address[] public owners;
    uint public numOfConfirmations;

    uint private numberExecuted;
    mapping (address => bool) private isOwner;
    mapping (uint => mapping (address => bool)) private confirmed;
    Transaction[] private txs;

    constructor(address[] memory _owners, uint _numOfConfirmations) {
        require(_owners.length > 0 && _numOfConfirmations > 0, "invalid input values");
        require(_numOfConfirmations <= _owners.length, "invalid number of confirmations");

        uint _length = _owners.length;

        for (uint i = 0; i < _length; i++) {
            address newOwner = _owners[i];
            require(newOwner != address(0), "owner cant be zero");
            require(!isOwner[newOwner], "not unique owner");
            owners.push(newOwner);

            isOwner[newOwner] = true;
        }
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not an owner");
        _;
    }

    modifier notConfirmed(uint index) {
        require(confirmed[index][msg.sender] == false, "already confirmed");
        _;
    }

    modifier notExectuted(uint index) {
        require(txs[index].executed == false, "already executed");
        _;
    }

    modifier txExists(uint index) {
        require(index < txs.length, "tx not exists");
        _;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(
        address _to,
        uint _value,
        bytes calldata _data
    ) external onlyOwner {
        uint index = txs.length;

        txs.push(Transaction({
            to: _to,
            executed: false,
            confirmations: 0,
            value: _value,
            data: _data
        }));

        emit SubmitTransaction(msg.sender, index, _to, _value, _data);
    }

    function confirmTransaction(uint index) external 
        onlyOwner 
        txExists(index) 
        notConfirmed(index)
        notExectuted(index)
    {
        confirmed[index][msg.sender] = true;
        txs[index].confirmations++;

        emit ConfirmTransaction(msg.sender, index);
    }

    function revokeConfirmation(uint index) external 
        onlyOwner
        txExists(index)
        notExectuted(index) 
    {
        require(confirmed[index][msg.sender], "not confirmed");
        confirmed[index][msg.sender] = true;
        txs[index].confirmations--;

        emit RevokeConfirmation(msg.sender, index);
    }

    function executeTransaction(uint index) external 
        onlyOwner 
        txExists(index)
        notExectuted(index)
    {
        require(txs[index].confirmations >= numOfConfirmations, "no enough confirmations");

        Transaction storage _tx = txs[index];
        _tx.executed = true;

        (bool success, ) = payable(_tx.to).call{value: _tx.value}(_tx.data);
        require(success, "tx failed");

        numberExecuted++;

        emit ExecuteTransaction(msg.sender, index);
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() external view returns (uint) {
        return txs.length;
    }

    function getNumOfExecutedTransactions() external view returns (uint) {
        return numberExecuted;
    }

    function getTransaction(uint index) external view txExists(index) returns (
        address to,
        uint value,
        bytes memory data,
        bool executed,
        uint confirmations
    ) {
        return (
            txs[index].to,
            txs[index].value,
            txs[index].data,
            txs[index].executed,
            txs[index].confirmations
        );
    }
}
