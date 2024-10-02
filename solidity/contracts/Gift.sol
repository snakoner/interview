
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

// This contract will avail withdrawal at birthday time
contract Gift {
    // contract creator
    address payable owner;

    // bank to share
    uint public bank;

    // number of members to share
    uint public counter;

    struct Unit {
        string name;
        bool exist;
        bool withdrawalOk;
        uint256 birthday;
    }

    // mapping for Units
    mapping (address => Unit) public units;
    mapping (address => bool) public blacklist;

    // array of Units
    address[] public unitAddresses;

    constructor() {
        owner = payable(msg.sender);
        counter = 0;
    }

    // modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    receive() external payable { }

    function addUnit(address addr, string calldata _name, uint256 _birthday) public onlyOwner  {
        require(
            !units[addr].exist, 
            "unit already exists"
        );

        unitAddresses.push(addr);
        units[addr] = Unit(_name, true, false, _birthday);

        counter += 1;
    }

    function perUnit() private view returns(uint256) {
        return bank / counter;
    }

    function setBank(uint256 _bank) public onlyOwner {
        bank = _bank;
    }

    function addToBlacklist(address addr) public onlyOwner {
        blacklist[addr] = true;
    }

    function removeFromBlacklist(address addr) public onlyOwner {
        blacklist[addr] = false;
    }

    function isInBlacklist() public view returns (bool) {
        return blacklist[msg.sender];
    }

    // balance of smart contract
    function balanceOf() public view returns (uint) {
        return address(this).balance;
    }

    event Withdrawal(address addr, string name, uint amount);

    function withdraw() public {
        require(
            units[msg.sender].exist, 
            "unit not exist"
        );
        
        require(
            !blacklist[msg.sender], 
            "unit in blacklist"
        );
        
        require(
            !units[msg.sender].withdrawalOk, 
            "have already withdrawal"
        );
        
        require(
            units[msg.sender].birthday >= block.timestamp, 
            "bithday not come yet"
        );

        units[msg.sender].withdrawalOk = true;
 
        uint256 amount = bank / counter;
        address payable recepient = payable(msg.sender);

        (bool success, ) = recepient.call{value: amount}("");
        require(success);

        emit Withdrawal(msg.sender, units[msg.sender].name, units[msg.sender].birthday);
    }
}
