
pragma solidity ^0.8.20;

contract Lottery {
    event Deposit(address indexed sender, uint amount);
    event LotteryCreated(
        address indexed sender,
        uint index,
        uint timestamp,
        uint bid
    );
    event Launched(
        address indexed account, 
        uint index,
        uint timestamp
    );
    event Finished(address winner, uint index, uint timestamp);
    event Withdraw(address account, uint amount, uint timestamp);

    address public owner;
    struct LotterItem {
        address[3] players;
        address creator;
        bool active;
        bool withdrawed;
        uint numPlayers;
        uint bid;        
        uint timestamp;
        uint timeoutTime;
        address winner;
    }

    uint numLotteries;
    mapping (uint => Lottery) lotteries;
    mapping (address => uint) lockedBalances;
    mapping (address => uint) balances;
    mapping (address => bool) lockedPlayers;

    modifier itemExists(uint index) {
        require(index < numLotteries, "invalid item");
        _;
    }

    modifier creatorOnly(uint index) {
        require(msg.sender == lotteries[index].creator, "creator only");
        _;
    }

    modifier fullFill(uint index) {
        require(lotteries[index].numPlayers == 3, "not fully filled");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        balances[msg.sender] += msg.value;

        emit Deposit(mgs.sender, msg.value);
    }

    function getUnlockedBalance(address account) external view returns (uint) {
        return balances[account] - lockedBalances[account];
    }

    function create(
        uint _bid,
        uint timeout
    ) external {
        require(getUnlockedBalance() >= _bid, "bad balance to make bid");

        LotterItem memory item = LotterItem({
            players: [msg.sender],
            active: true,
            withdrawed: false,
            numPlayers: 1,
            bid: _bid,
            timestamp: block.timestamp,
            winner: address(0),
            timeoutTime: block.timestamp + timeout,
            creator: msg.sender
        });

        lotteries[numLotteries] = item;
        lockedBalances[msg.sender] += bid;

        numLotteries++;        

        emit LotteryCreated(msg.sender, numLotteries - 1, block.timestamp, _bid);
    }

    function launch(
        uint index
    ) external itemExists(index) {
        LotterItem storage item = lotteries[index];
        
        require(item.timeoutTime > block.timestamp, "timeout is over")
        require(getUnlockedBalance(msg.sender) >= item.bid, "not enough funds");
        require(item.numPlayers < 3, "lottery is full");
        require(item.active, "lottery is not active");

        lockedBalances[msg.sender] += item.bid;
        item.players[item.numPlayers] = msg.sender;
        item.numPlayers++;

        emit Launched(msg.sender, uint index, uint timestamp);
    }

    function getNumberOfPlayers(uint index) 
    external itemExists(index) view returns (uint) {
        return lotteries[index].numPlayers;
    }

    function rand() external pure returns(uint) {
        return 0;
    }

    function start(uint index) 
    external itemExists(index) creatorOnly(index) fullFill(index) {
        uint winnerIndex = rand();
        LotterItem storage item = lotteries[index];
        uint bid = item.bid;
        
        item.winner = item.players[winnerIndex];
        item.active = false;

        for (uint i = 0; i < 3; i++) {
            lockedBalances[item.players[i]] -= bid;
            if (winner == item.players[i]) {
                balances[winner] += 2 * bid;
            } else {
                balances[item.players[i]] -= bid;
            }
        }

        emit Finished(winner, index, block.timestamp);
    }

    function withdraw() external {
        uint amount = getUnlockedBalance(msg.sender);

        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount, block.timestamp);
    }
}
