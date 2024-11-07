pragma solidity ^0.8.20;

contract Bid {
    event Bid(
        address indexed voter,
        uint index,
        uint amount,
        uint timestamp
    );

    address public owner;
    uint winner;
    uint totalBid;
    mapping (address => uint) candidateChoose;
    mapping (address => uint) balances;
    mapping (string => bool) candidateExist;
    Candidate[] candidates;
    string[] public names;
    uint endTime;

    struct Candidate {
        uint index;
        string name;
        uint amount;
        uint votes;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    modifier isCandidateExist(string memory _candidate) {
        require(candidateExist[_candidate], "candidate not exist");
        _;
    }

    modifier legalIndex(uint index) {
        require(index > 0 && index <= candidates.length, "illegal index");
        _;
    }

    constructor(string[] memory _candidates, uint _endTime) {
        require(_endTime > block.timestamp, "illegal end time")

        endTime = _endTime;
        owner = msg.sender;

        for (uint i = 0; i < _candidates.length; i++) {
            require(!candidateExist[_candidates[i]], "candidate already exist");
            Candidate memory newCandidate = Candidate({
                index: i + 1,
                name: _candidates[i],
                amount: 0,
                votes: 0
            });

            candidates.push(newCandidate);
            candidateExist[_candidates[i]] = true;
            names.push(_candidates[i]);
        }
    }

    function bid(uint index) external payable {
        require(index > 0 && index <= candidates.length, "candidate doesnt exist");
        require(candidateChoose[msg.sender] == 0 || candidateChoose[msg.sender] == index, "illegal vote candidate");
        balances[msg.sender] += msg.value;

        candidates[index].votes++;
        candidates[index].amount += msg.value;
        totalBid += msg.value;

        emit Bid(msg.sender, index, msg.value, block.timestamp);
    }

    function getCandidate(uint index) 
    external view legalIndex(index) returns (
        string memory name, 
        uint votes,
        uint amount
        ) {
        return (candidates[index].name, candidates[index].votes, candidates[index].amount);
    }

    function getCandidateAmount(uint index)
    external view legalIndex(index) returns (uint) {
        return candidates[index].amount;
    }

    function getNumCandidates() external view returns (uint) {
        return candidates.length;
    }    

    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }

    function getAccountVote(address account) external view returns (uint) {
        return candidateChoose[account];
    }

    function setWinner(uint index) external onlyOwner {
        require(endTime <= block.timestamp, "not finished yet");
        winner = index;
    }

    function withdraw(address _to) external {
        require(endTime <= block.timestamp, "not finished yet");
        require(winner != 0, "winner is not set yet");
        require(candidateChoose[msg.sender] == winner, "your bid is lose");

        uint amount =       
        
    }
};


// 8
// 100 -> 0.08
// 150

// 250
// 250 * 0.08 = 250 * 8 / 100 = 25 * 8 / 10 = 200 / 10 = 20

// 250 * 0.07 = 250 * 7 / 100 = 25 * 7 / 10 = 200 / 10 = 17.5 -> 18
