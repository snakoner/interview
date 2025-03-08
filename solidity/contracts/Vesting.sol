
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenLock is Ownable {
    error UnauthorizedAccess();
    error InvalidVestingParams();
    error UnlockPeriodCompleted();
    error TransferFailed();
    error InsufficientClaimableBalance();

    event TokenSaleUpdated(
        address indexed tokenSale
    );

    event Locked(
        address indexed recepient,
        uint256 amount
    );

    event Claimed(
        address indexed recepient,
        uint256 amount
    );

    struct VestingParams {
        uint64 unlockStart;
        uint64 unlockEnd;
        uint64 unlockCliff; // from this time start linear unlock
        uint256 lockedAmounts;
        uint256 claimedAmounts;
    }

    IERC20 public immutable token;
    address public tokenSale;
    mapping (address => VestingParams) public vesting;

    constructor(IERC20 _token) Ownable(msg.sender) {
        token = _token;
    }

    function setTokenSale(address _tokenSale) external onlyOwner {
        tokenSale = _tokenSale;

        emit TokenSaleUpdated(_tokenSale);
    }

    function setupVesting(
        address recepient,
        uint64 _unlockStart,
        uint64 _unlockCliff,
        uint64 _unlockEnd
    ) external {
        require(
            msg.sender == owner() || 
            msg.sender == tokenSale, 
            UnauthorizedAccess()
        );

        require(_unlockCliff >= _unlockStart, InvalidVestingParams());
        require(_unlockCliff <= _unlockEnd, InvalidVestingParams());

        vesting[recepient].unlockStart = _unlockStart;
        vesting[recepient].unlockEnd = _unlockEnd;
        vesting[recepient].unlockCliff = _unlockCliff;
    }

    function lock(address recepient, uint256 amount) external {
        require(uint64(block.timestamp) < vesting[recepient].unlockEnd, UnlockPeriodCompleted());

        vesting[recepient].lockedAmounts += amount;
        require(
            token.transferFrom(msg.sender, address(this), amount), 
            TransferFailed()
        );

        emit Locked(recepient, amount);
    }

    function claimableBalance(address recepient) public view returns (uint256) {
        if (uint64(block.timestamp) < vesting[recepient].unlockCliff) 
            return 0;

        uint256 locked = vesting[recepient].lockedAmounts;
        uint256 claimed = vesting[recepient].claimedAmounts;
        uint64 end = vesting[recepient].unlockEnd;

        if (uint64(block.timestamp) >= end)
            return locked - claimed;

        uint64 start = vesting[recepient].unlockStart;
        return locked * (uint64(block.timestamp) - start) / (end - start) - claimed;
    }

    function claim(address recepient, uint256 amount) external {
        uint256 claimable = claimableBalance(recepient);
        if (amount > claimable)
            amount = claimable;
        
        require(amount != 0, InsufficientClaimableBalance());

        vesting[recepient].claimedAmounts += amount;

        require(token.transfer(recepient, amount), TransferFailed());

        emit Claimed(recepient, amount);
    } 
}
