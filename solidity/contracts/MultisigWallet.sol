// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IWallet {
    error InvalidConstructorData(address failedAccount);
    error RoleAlreadySet();
    error RoleNotSet();
    error UnauthorizedAccess();
    error UnexpectedTransactionState(bytes32 expectedState);
    error InsufficientEthSent();
    error AlreadyConfirmed();
    error NotEnoughConfirmations();
    error TransactionFailed();
    error InvalidConfirmatorsNumber();

    event ExecutorAdded(address indexed account);
    event ConfirmatorAdded(address indexed account);
    event ConfirmatorRemoved(address indexed account);
    event ProposerAdded(address indexed account);
    event TransactionScheduled(bytes32 indexed _hash);
    event TransactionConfirmed(bytes32 indexed _hash);
    event TransactionExecuted(bytes32 indexed _hash);
    event TransactionClosed(bytes32 indexed _hash);
}

contract Wallet is Ownable, IWallet {
    enum TransactionState {
        NonExist,
        Created,
        Closed,
        Executed
    }

    struct Transaction {
        uint256 value;        
        uint256 nonce;
        bytes data;
        address to;
        TransactionState state;
        uint64 confirmations;
    }

    mapping (bytes32 _hash => Transaction) private _transactions;
    mapping (bytes32 _hash => mapping (address => bool)) private _confirmed;
    mapping (address => bool) private _confirmators;
    mapping (address => bool) private _executors;
    mapping (address => bool) private _proposers;
    uint64 private numConfirmators;
    uint64 public immutable MIN_CONFIRMATIONS;

    modifier onlyProposer(address account) {
        require(_proposers[account], UnauthorizedAccess());
        _;
    }

    modifier onlyConfirmator(address account) {
        require(_confirmators[account], UnauthorizedAccess());
        _;
    }

    modifier onlyExecutor(address account) {
        require(_executors[account], UnauthorizedAccess());
        _;
    }

    constructor(
        uint64 _minConfirmations,
        address[] memory confirmators,
        address[] memory executors,
        address[] memory proposers
    ) Ownable(_msgSender()) {
        uint256 confirmatorsLength = confirmators.length;
        require(_minConfirmations <= confirmatorsLength);

        numConfirmators = uint64(confirmatorsLength);
        for (uint256 i = 0; i < confirmatorsLength; i++) {
            require(!_confirmators[confirmators[i]], InvalidConstructorData(confirmators[i]));
            _confirmators[confirmators[i]] = true;

            emit ExecutorAdded(confirmators[i]);
        }

        for (uint256 i = 0; i < executors.length; i++) {
            require(!_executors[executors[i]], InvalidConstructorData(executors[i]));
            _executors[executors[i]] = true;

            emit ExecutorAdded(executors[i]);
        }

        for (uint256 i = 0; i < proposers.length; i++) {
            require(!_proposers[proposers[i]], InvalidConstructorData(proposers[i]));
            _proposers[proposers[i]] = true;

            emit ProposerAdded(proposers[i]);
        }

        MIN_CONFIRMATIONS = _minConfirmations;
    }

    function schedule(
        uint256 value,
        address to,
        bytes calldata data,
        uint256 nonce
    ) external payable onlyProposer(msg.sender) {
        bytes32 _hash = hashify(value, nonce, to, data);
        require(
            _transactions[_hash].state == TransactionState.NonExist, 
            UnexpectedTransactionState(_decodeState(TransactionState.NonExist))
        );

        require(msg.value >= value, InsufficientEthSent());

        _transactions[_hash] = Transaction({
            value: msg.value,
            nonce: nonce,
            data: data,
            to: to,
            state: TransactionState.Created,
            confirmations: 0            
        });

        emit TransactionScheduled(_hash);
    }

    function confirm(bytes32 _hash) external onlyConfirmator(msg.sender) {
        TransactionState state = _transactions[_hash].state;
        require(
            state == TransactionState.Created, 
            UnexpectedTransactionState(_decodeState(TransactionState.Created))
        );

        require(!_confirmed[_hash][msg.sender], AlreadyConfirmed());
        _transactions[_hash].confirmations += 1;
        _confirmed[_hash][msg.sender] = true;

        emit TransactionConfirmed(_hash);
    }

    function execute(bytes32 _hash) external onlyExecutor(msg.sender) {
        Transaction storage _tx = _transactions[_hash];
        TransactionState state = _tx.state;
        require(
            state == TransactionState.Created, 
            UnexpectedTransactionState(_decodeState(TransactionState.Created))
        );

        require(_tx.confirmations >= MIN_CONFIRMATIONS, NotEnoughConfirmations());
        _tx.state = TransactionState.Executed;
        (bool success, ) = _tx.to.call{value: _tx.value}(_tx.data);
        require(success, TransactionFailed());

        emit TransactionExecuted(_hash);
    }

    function close(bytes32 _hash) external onlyProposer(msg.sender) {
        TransactionState state = _transactions[_hash].state;
        require(
            state == TransactionState.Created, 
            UnexpectedTransactionState(_decodeState(TransactionState.Created))
        );

        _transactions[_hash].state = TransactionState.Closed;

        emit TransactionClosed(_hash);
    }

    function _decodeState(TransactionState state) internal pure returns (bytes32) {
        return bytes32(1 << uint8(state));
    }

    function addConfirmator(address confirmator) external onlyOwner {
        require(!_confirmators[confirmator], RoleAlreadySet());

        _confirmators[confirmator] = true;
        numConfirmators++;
        emit ConfirmatorAdded(confirmator);
    }

    function removeConfirmator(address confirmator) external onlyOwner {
        require(numConfirmators - 1 >= MIN_CONFIRMATIONS, InvalidConfirmatorsNumber());
        require(_confirmators[confirmator], RoleNotSet());

        _confirmators[confirmator] = false;
        numConfirmators--;
        emit ConfirmatorRemoved(confirmator);
    }

    function addProposer(address proposer) external onlyOwner {
        require(!_proposers[proposer], RoleAlreadySet());

        _proposers[proposer] = true;
        emit ProposerAdded(proposer);
    }

    function removeProposer(address proposer) external onlyOwner {
        require(_proposers[proposer], RoleNotSet());

        _proposers[proposer] = false;
        emit ProposerAdded(proposer);
    }

    function hashify(
        uint256 value,
        uint256 nonce,
        address to,
        bytes calldata data
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(value, to, data, nonce));
    }
}
