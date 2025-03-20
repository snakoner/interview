### haircutReserves

```solidity
function haircutReserves(address l1Token, int256 haircutAmount) public onlyOwner nonReentrant {
    pooledTokens[l1Token].utilizedReserves -= haircutAmount;
}
```

1. we add liquidity, for example `l1TokenAmount = 100000` tokens, get `lpTokenAmount = (l1TokenAmount * 1e18) / _exchangeRateCurrent(l1Token)`
2. owner executes haircutReserves() and changes utilizedReserves
3. we remove liquidity and get `l1Tokens = (lpTokenAmount * _exchangeRateCurrent(l1Token)) / 1e18`


#### Simulation

```
get some real params for WETH contract:

address lpToken = 0x28F77208728B0A45cAb24c4868334581Fe86F95B
uint32 lastLpFeeUpdate = 1742478023
uint256 undistributedLpFees = 2495510634873076907
uint256 liquidReserves = 15593038486308420640717
int256 utilizedReserves = 3081310457640993279566
```


```solidity
contract Attack {
    uint256 undistributedLpFees = 2495510634873076907;
    uint256 liquidReserves = 15593038486308420640717;
    uint256 totalSupply = 17029603465356381254203;
    int256 utilizedReserves = 3081310457640;  // can change

    function exchangeRate() public view returns (uint256) {
        // _updateAccumulatedLpFees(pooledToken); 
        // _sync(l1Token);

        int256 numerator = int256(liquidReserves) + utilizedReserves - int256(undistributedLpFees);
        return (uint256(numerator) * 1e18) / totalSupply;
    }

    function removeLiquidity(uint256 lpTokenAmount) external view returns (uint256) {
        return (lpTokenAmount * exchangeRate()) / 1e18;
    }
}

// *** assume we have 100000 lpTokens:
// 1. int256 utilizedReserves = 3081310457640993279566
// 2. lpTokens = 100000
// 3. l1Token = 109643

// *** increase utilizedReserves, haircutAmount < 0 -> we get more l1 tokens than deposited: 
// 1. int256 utilizedReserves = 3081310457640993279566000
// 2. lpTokens = 100000
// 3. l1Token = 18185397

// *** increase utilizedReserves, haircutAmount < 0 -> we get less l1 tokens than deposited: 
// 1. int256 utilizedReserves = 3081310457640
// 2. lpTokens = 100000
// 3. l1Token = 91549

// *** increase utilizedReserves, haircutAmount < 0 -> we get less l1 tokens than deposited: 
// *** !!! have saturation
// 1. int256 utilizedReserves = 308131045
// 2. lpTokens = 100000
// 3. l1Token = 91549
```

> _updateAccumulatedLpFees(pooledToken) and _sync(l1Token) don't affect on exchangeRate, if only haircutReserves() was called
        

