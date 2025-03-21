https://backoffice.shiftam.com/building_blocks/protocols/678ba6b3-2dba-4536-a6d2-f0c4565adfe8/it_audit/smart_contracts/69c653c6-11aa-4cdd-a742-61abd9f8c2d5/smart_contract_audit_report

```
0x98dd95D0ac5b70B0F4ae5080a1C2EeA8c5c48387 - curveVault
0x69D61428d089C2F35Bf6a472F540D0F82D1EA2cd - curveStrategy
0x28766020a5A8D3325863Bf533459130DDb0c3657 - gauge:
	staking_token = 0x98dd95D0ac5b70B0F4ae5080a1C2EeA8c5c48387  (curveVault is ERC20Upgradeable)
```

### setLiquidityGauge

ERC20Upgradeable public token; - is token that users deposit (declared and set in CurveVault), lets call it as token1
contract CurveVault is ERC20Upgradeable - some type of lp token, lets call it as token2


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

1. All old deposits(of token2) are held on liquidityGauge address
2. Governance can change liquidityGauge address, but all funds will be still on old liquidityGauge address
3. If liquidityGauge address changes, it's possible to steal funds (token1) from msg.sender while executing from (msg.sender).deposit()

Possible vector attack:
1. Account wants to deposit N ERC20 tokens(token1), assume its big amount
2. Attacker sees this tx im mempool. Governance with high eth priority_fee transactions changes liquidityGauge address:
```solidity

// its possible because before executing ILiquidityGaugeStrat(liquidityGauge).deposit(_amount, _staker)
// msg.sender transfer _amount of ERC20 token to CurveVault address

contract Gauge {
	function deposit(uint256 _value, address _addr) external {
		// here is msg.sender == address(CurveVault) with _amount balance
		// here is token is token1 address, which user try to deposit
		token.transfer(<SOME_ADDRESS or address(this)>, _value);
	}
}
```

### setCurveStrategy
```solidity
function setCurveStrategy(CurveStrategy _newStrat) external {
	require(msg.sender == governance, "!governance");
	require(address(_newStrat) != address(0), "zero address");
	// migration (send all LPs here)
	curveStrategy.migrateLP(address(token));
	curveStrategy = _newStrat;
	// deposit LPs into the new strategy
	earn();
}

function earn() internal {
	uint256 tokenBalance = available();
	token.approve(address(curveStrategy), 0);
	token.approve(address(curveStrategy), tokenBalance);
	curveStrategy.deposit(address(token), tokenBalance);
	emit Earn(address(token), tokenBalance);
}
```

1. By changing curveStrategy contract address its possible to withdraw all ???

### setGovernance
It does not directly affect the security of a smart contract

### setWithdrawnFee

```solidity
function setWithdrawnFee(uint256 _newFee) external {
	require(msg.sender == governance, "!governance");
	require(_newFee <= MAX, "more than 100%");
	withdrawalFee = _newFee;
}
```

1. For example, governance sets withdrawalFee = 9999 (99.99%)
2. Account wants to withdraw all shares:
```solidity
function withdraw(uint256 _shares) public {
	uint256 userTotalShares = ILiquidityGaugeStrat(liquidityGauge).balanceOf(msg.sender);
	require(_shares <= userTotalShares, "Not enough staked");
	ILiquidityGaugeStrat(liquidityGauge).withdraw(_shares, msg.sender, true);
	_burn(address(this), _shares);
	uint256 tokenBalance = token.balanceOf(address(this)) - accumulatedFee;
	uint256 withdrawFee;
	if (_shares > tokenBalance) {
		uint256 amountToWithdraw = _shares - tokenBalance;
		curveStrategy.withdraw(address(token), amountToWithdraw);
		withdrawFee = (amountToWithdraw * withdrawalFee) / 10000;
		token.safeTransfer(governance, withdrawFee);
	}
	token.safeTransfer(msg.sender, _shares - withdrawFee);
	emit Withdraw(msg.sender, _shares - withdrawFee);
}

```
3. withdrawFee = (amountToWithdraw * withdrawalFee) / 10000 ~ amountToWithdraw
4. token.safeTransfer(governance, withdrawFee) -> governance receive get all token1 that user wants to withdraw
5. token.safeTransfer(msg.sender, _shares - withdrawFee); -> account will receive ~0 token1 amount
6. furthermore, all users that want to withdraw will lose their token1 tokens, governance will receive all funds

### setKeeperFee
???
