// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Staking {
    using SafeERC20 for IERC20;

    error ZeroDepositAmount();
    error ZeroWithdrawAmount();
    error InsufficientWithdrawAmount();

    event Staked(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount, uint256 rewardAmount);

    struct StakeInfo {
        uint256 amount;
        uint256 rewardAmount;
        uint256 startTime;  // use uint256 to not cut
    }

    uint256 immutable public REWARD_PER_SECOND; // for 1 token staked for 1 second
    mapping (address => StakeInfo) public stakes;
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    constructor(
        address _stakingToken, 
        address _rewardToken, 
        uint256 rewardPerSecond
    ) {
        REWARD_PER_SECOND = rewardPerSecond;
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256 amount) external {
        require(amount != 0, ZeroDepositAmount());
        StakeInfo storage stake = stakes[msg.sender];

        uint256 stakeAmount = stake.amount;
        if (stakeAmount != 0)
            stake.rewardAmount += calculateReward(stakeAmount, stake.startTime);

        stake.amount += amount;
        stake.startTime = block.timestamp;

        token.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        StakeInfo storage _stake = stakes[msg.sender];

        uint256 stakeAmount = _stake.amount;
        require(stakeAmount >= amount, InsufficientWithdrawAmount());

        uint256 startTime = _stake.startTime;
        uint256 reward = _stake.rewardAmount + calculateReward(amount, startTime);

        _stake.rewardAmount = 0;
        _stake.amount -= amount;
        _stake.startTime = block.timestamp;

        stakingToken.safeTransfer(msg.sender, amount);
        rewardToken.safeTransfer(msg.sender, reward);

        emit Withdraw(msg.sender, amount, reward);
    }

    function calculateReward(
        uint256 amount, 
        uint256 startTime
    ) public view returns (uint256 reward) {
        return amount * ((block.timestamp - startTime) * REWARD_PER_SECOND);
    }
}
