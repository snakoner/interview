### setLiquidityGauge

```solidity
interface ILiquidityGaugeStrat {
	function withdraw(
		uint256 _value,
		address _addr,
		bool _claim_rewards
	) external;
	// solhint-disable-next-line
	function reward_data(address _tokenReward) external view returns (Reward memory);
	function balanceOf(address) external returns (uint256);
	function claimable_reward(address _user, address _reward_token) external view returns (uint256);
	function user_checkpoint(address _user) external returns (bool);
	function commit_transfer_ownership(address) external;
	function initialize(
		address _staking_token,
		address _admin,
		address _SDT,
		address _voting_escrow,
		address _veBoost_proxy,
		address _distributor,
		address _vault,
		string memory _symbol
	) external;
	function add_reward(address, address) external;
	function set_claimer(address) external;
}


function setLiquidityGauge(address _liquidityGauge) external {
    require(msg.sender == governance, "!governance");
    require(_liquidityGauge != address(0), "zero address");
    liquidityGauge = _liquidityGauge;
}
```

