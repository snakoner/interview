// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    address public owner;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    string _name;
    string _symbol;
    uint _totalSupply;

    function name() external view returns(string memory) {
        return _name;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    function decimals() external pure returns(uint) {
        return 18;
    }

    modifier enoughTokens(address _from, uint _amount) {
        require(balanceOf(_from) >= _amount, "not enough tokens");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner");
        _;
    }

     constructor(
        string memory __name, 
        string memory __symbol, 
        uint initialSupply,
        address shop) {
        _name = __name;
        _symbol = __symbol;

        // чеканка монет
        mint(initialSupply, shop);
    }

    function mint(uint amount, address to) public onlyOwner {
        _beforeTokenTransfer(address(0), to, amount);
        balances[to] += amount;
        _totalSupply += amount;

        emit Transfer(address(0), to, amount);
    }

    function totalSupply() external view returns(uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns(uint) {
        return balances[account];
    }

    // функция из openZeppelin
    function _beforeTokenTransfer(address _from, address _to, uint amount) internal virtual {

    }

    function transfer(address to, uint amount) external enoughTokens(msg.sender, amount) {
        _beforeTokenTransfer(msg.sender, to, amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }

    function allowance(address _owner, address _spender) public view returns(uint) {
        return allowances[_owner][_spender];
    }

    // функция из openZeppelin
    function _approve(address _sender, address _spender, uint amount) internal virtual {
        allowances[_sender][_spender] = amount;
        emit Approve(_sender, _spender, amount);
    }

    function approve(address spender, uint amount) public {
        _approve(msg.sender, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint amount) external enoughTokens(sender, amount) {
        _beforeTokenTransfer(sender, recipient, amount);

        require(allowances[sender][recipient] >= amount, "not allowed amount");

        allowances[sender][recipient] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function burn(address from, uint amount) public onlyOwner enoughTokens(from, amount) {
        _beforeTokenTransfer(from, address(0), amount);

        balances[from] -= amount;
        _totalSupply -= amount;

        emit Transfer(from, address(0), amount);
    }
}

contract PepeToken is ERC20 {
    constructor(address shop) ERC20("Pepe Token", "PEPE", 10000000000, shop) {}

    // function _beforeTokenTransfer(address _from, address _to, uint amount) internal override {
    //     require(_from != address(0), "zero address");
    // }
}

contract Shop {
    IERC20 public token;
    address payable public owner;

    event Bought(address buyer, uint amount);
    event Sold(address seller, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner");
        _;
    }

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
        owner = payable(msg.sender);
    }

    receive() external payable {
        uint amount = msg.value;    // 1 wei = 1 token
        require(amount > 0, "not enough funds");

        uint currentSupply = token.totalSupply();
        require(currentSupply >= amount, "not enough tokens in supply");

        token.transfer(msg.sender, amount);
        emit Bought(msg.sender, amount);
    }

    function sell(uint amount) external {
        require(amount > 0, "invalid amount");
        require(token.balanceOf(msg.sender) >= amount, "incorrect amount");
        require(token.allowance(msg.sender, address(this)) >= amount, "incorrect allowance");

        token.transferFrom(msg.sender, address(this), amount);
        emit Sold(msg.sender, amount);

        // если курс другой, то нужно пересчитать amount
        payable(msg.sender).transfer(amount);
    }

    function tokenBalance() public view returns(uint) {
        return token.balanceOf(address(this));
    }
}
