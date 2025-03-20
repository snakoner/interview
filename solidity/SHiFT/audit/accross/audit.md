### haircutReserves

```solidity
function haircutReserves(address l1Token, int256 haircutAmount) public onlyOwner nonReentrant {
    pooledTokens[l1Token].utilizedReserves -= haircutAmount;
}
```

1. we add liquidity, for example `l1TokenAmount = 100000` tokens, get `lpTokenAmount = (l1TokenAmount * 1e18) / _exchangeRateCurrent(l1Token)`

get some params for WETH:
```
address lpToken :  0x28F77208728B0A45cAb24c4868334581Fe86F95B
lastLpFeeUpdate   uint32 :  1742478023
undistributedLpFees   uint256 :  2495510634873076907
liquidReserves   uint256 :  15593038486308420640717
utilizedReserves   int256 : 3081310457640993279566
```

2. owner executes haircutReserves() and changes utilizedReserves
3. we remove liquidity and get `l1Tokens = (lpTokenAmount * _exchangeRateCurrent(l1Token)) / 1e18`



```
contract Attack {
    // real params from contract
    uint256 undistributedLpFees = 2495510634873076907;
    uint256 liquidReserves = 15593038486308420640717;
    uint256 totalSupply = 17029603465356381254203;
    int256 utilizedReserves = 3081310457640;  // can change

    function exchangeRate() public view returns (uint256) {
        int256 numerator = int256(liquidReserves) + utilizedReserves - int256(undistributedLpFees);
        return (uint256(numerator) * 1e18) / totalSupply;
    }

    function removeLiquidity(uint256 lpTokenAmount) external view returns (uint256) {
        return (lpTokenAmount * exchangeRate()) / 1e18;
    }
}

assume we have 100000 lpTokens:
1. int256 utilizedReserves = 3081310457640993279566
2. lpTokens = 100000
3. l1Token = 109643

1. int256 utilizedReserves = 3081310457640993279566000
2. lpTokens = 100000
3. l1Token = 18185397

1. int256 utilizedReserves = 3081310457640
2. lpTokens = 100000
3. l1Token = 91549

1. int256 utilizedReserves = 308131045
2. lpTokens = 100000
3. l1Token = 91549
```

