// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IATokenReceiver {
    error UnauthorizedOperator(address sender);
    error OperatorExists(address operator);
    error OperatorNotExists(address operator);

    error TradeZeroAmountForbidden();
    error TradeAlreadyExists(bytes32 id);
    error UnexpectedTradeState(uint8 expectedState, uint8 currentState);
    error NotTradeOwner();
    error InsufficientAmountToWithdraw();
    error ConfirmWindowExpired();
    error LockDurationNotExpired();

    error LockDurationLessThanConfirmWindow();
    error ConfirmWindowGreaterThanLockDuration();

    event UpdateLockDuration(
        uint64 oldLockDuration,
        uint64 newLockDuration
    );

    event UpdateConfirmWindow(
        uint64 oldConfirmWindow,
        uint64 newConfirmWindow
    );

    event CreateTrade(
        bytes32 indexed id,
        address indexed from,
        uint256 amount
    );

    event ConfirmTrade(bytes32 indexed id);
    event RejectTrade(bytes32 indexed id);
    event WithdrawTrade(bytes32 indexed id);

    event AddOperator(address operator);
    event RemoveOperator(address operator);
}

enum TradeState {
    None,      // not created
    Locked,    // trade is in progress
    Confirmed, // trade is executed
    Rejected,    // trade in rejected by operator, can transfer tokens back
    Released   // 'from' can transfer tokens back
}

struct Trade {
    address from;
    uint64 startAt;
    TradeState state;
    uint256 amount;
}

contract ATokenReceiver is IATokenReceiver, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    IERC20 public immutable _token;
    EnumerableSet.AddressSet private _operators;

    mapping (bytes32 => Trade) public trades;
    uint256 public tradeNumber;
    uint256 public confirmedAmount;
    uint64 public lockDuration;
    uint64 public confirmWindow;

    modifier onlyOperator() {
        if (!_operators.contains(msg.sender)) revert UnauthorizedOperator(msg.sender);
        _;
    }

    constructor(
        address initialOwner,
        address token,
        uint64 _lockDuration,
        uint64 _confirmDuration
    ) Ownable(initialOwner) {
        _token = IERC20(token);
        updateLockDuration(_lockDuration);
        updateConfirmWindow(_confirmDuration);
    }

    function createTrade(
        bytes32 id,
        address from,
        uint256 amount
    ) external onlyOperator {
        if (amount == 0) revert TradeZeroAmountForbidden();
        if (trades[id].state != TradeState.None) revert TradeAlreadyExists(id);

        trades[id] = Trade({
            from: from,
            startAt: uint64(block.timestamp),
            state: TradeState.Locked,
            amount: amount
        });

        unchecked {tradeNumber++;}

        _token.safeTransferFrom(from, address(this), amount);

        emit CreateTrade(id, from, amount);
    }

    // trade is confirmed by operator -> can't take tokens back
    function confirmTrade(bytes32 id) external onlyOperator {
        Trade storage t = trades[id];
        TradeState state = t.state;
        if (state != TradeState.Locked)
            revert UnexpectedTradeState(
                _decodeState(TradeState.Locked),
                _decodeState(state)
            );

        if (uint64(block.timestamp) > t.startAt + confirmWindow) revert ConfirmWindowExpired();

        confirmedAmount += t.amount;
        t.state = TradeState.Confirmed;

        emit ConfirmTrade(id);
    }

    // TODO: probably, send funds back
    function rejectTrade(bytes32 id) external onlyOperator {
        Trade storage t = trades[id];
        TradeState state = t.state;

        if(state != TradeState.Locked)
            revert UnexpectedTradeState(
                _decodeState(TradeState.Locked),
                _decodeState(state)
            );

        if (uint64(block.timestamp) > t.startAt + confirmWindow) revert ConfirmWindowExpired();

        t.state = TradeState.Rejected;
        _token.safeTransfer(t.from, t.amount);

        emit RejectTrade(id);
    }

    // user function to withdraw rejected or expired(unlocked) funds
    function withdrawTrade(bytes32 id) external {
        Trade storage t = trades[id];

        address from = t.from;
        if (msg.sender != from) revert NotTradeOwner();

        TradeState state = t.state;
        if (state == TradeState.Confirmed)
            revert UnexpectedTradeState(
                _decodeState(TradeState.Rejected),
                _decodeState(state)
            );

        if (state == TradeState.Locked) {
            if (uint64(block.timestamp) <= t.startAt + lockDuration)
                revert LockDurationNotExpired();
        } else if (state != TradeState.Rejected) {
            revert UnexpectedTradeState(
                _decodeState(TradeState.Rejected),
                _decodeState(state)
            );
        }

        t.state = TradeState.Released;
        _token.safeTransfer(from, t.amount);

        emit WithdrawTrade(id);
    }

    // service
    function addOperators(
        address[] calldata operators
    ) external onlyOwner {
        uint256 length = operators.length;
        for (uint256 i = 0; i < length;) {
            if (_operators.contains(operators[i])) revert OperatorExists(operators[i]);

            _operators.add(operators[i]);
            emit AddOperator(operators[i]);

            unchecked {++i;}
        }
    }

    function removeOperators(
        address[] calldata operators
    ) external onlyOwner {
        uint256 length = operators.length;
        for (uint256 i = 0; i < length;) {
            if (!_operators.contains(operators[i])) revert OperatorNotExists(operators[i]);

            _operators.remove(operators[i]);
            emit RemoveOperator(operators[i]);

            unchecked {++i;}
        }
    }

    function updateLockDuration(uint64 newLockDuration) public onlyOwner {
        if(newLockDuration <= confirmWindow) revert LockDurationLessThanConfirmWindow();
        emit UpdateLockDuration(lockDuration, newLockDuration);

        lockDuration = newLockDuration;
    }

    function updateConfirmWindow(uint64 newConfirmWindow) public onlyOwner {
        if (newConfirmWindow >= lockDuration) revert ConfirmWindowGreaterThanLockDuration();
        emit UpdateConfirmWindow(confirmWindow, newConfirmWindow);

        confirmWindow = newConfirmWindow;
    }

    function withdrawConfirmed(address to, uint256 amount) external onlyOwner {
        if (amount > confirmedAmount) revert InsufficientAmountToWithdraw();
        unchecked {confirmedAmount -= amount;}

        _token.safeTransfer(to, amount);
    }

    function _decodeState(TradeState state) internal pure returns (uint8) {
        return uint8(state);
    }
}
