### setLiquidityGauge

```solidity
function setLiquidityGauge(address _liquidityGauge) external {
    require(msg.sender == governance, "!governance");
    require(_liquidityGauge != address(0), "zero address");
    liquidityGauge = _liquidityGauge;
}

interface ILiquidityGaugeStrat {
	function deposit(uint256 _value, address _addr) external;
}


```

1. All old deposits are held on liquidityGauge address
2. Governance can change liquidityGauge address, but all funds will be still on old liquidityGauge address
3. If liquidityGauge address changes, it's possible to steal funds from msg.sender while executing from (msg.sender).deposit()

Possible vector attack:
1. Account wants to deposit N ERC20 tokens (assume its big amount)
2. Attacker sees this tx im mempool. Governance with high eth priority_fee transactions changes liquidityGauge address:
```solidity
// its possible because before executing ILiquidityGaugeStrat(liquidityGauge).deposit(_amount, _staker)
// msg.sender transfer _amount of ERC20 token to CurveVault address

contract Gauge {
	function deposit(uint256 _value, address _addr) external {
		// here is msg.sender == address(CurveVault) with _amount balance
		token.transfer(<SOME_ADDRESS or address(this)>, _value);
	}
}
```
