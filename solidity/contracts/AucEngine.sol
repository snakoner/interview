// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;


contract AucEngine {
    address public owner;
    uint constant DURATION = 2 days;    // compiler will transform day to seconds
    uint constant FEE = 10; // 10%

    struct Auction {
        address payable seller;
        uint startPrice;        // max price (means start price)
        uint finalPrice;         // price of sell
        uint startAt;           // unix timestamp of start time of auction
        uint endAt;             // unix timestamp of end time of auction
        uint discountRate;      // сколько сбрасываем каждую секунду от цены, wei
        string item;            // description of item
        bool stopped;           // if auction stopped
    }

    // events
    event AuctionCreated(uint index, string item, uint startPrice, uint duration);
    event AuctionEnded(uint index, address winner, uint finalPrice);

    Auction[] public auctions;

    constructor() {
        owner = msg.sender;
    }

    function createAuction(
        uint _startPrice,
        uint _discountRate,
        string calldata _item,
        uint _duration
    ) external {
        uint duration = _duration == 0 ? DURATION : _duration;

        require (
            _startPrice >= _discountRate * duration,
            "incorrect starting price"
        );

        Auction memory newAuction = Auction(
            payable(msg.sender),
            _startPrice,
            _startPrice,
            block.timestamp,
            block.timestamp + duration,
            _discountRate,
            _item,
            false
        );

        auctions.push(newAuction);

        // white to journal
        emit AuctionCreated(auctions.length - 1, _item, _startPrice, duration);
    }

    function getPrice(uint index) public view returns (uint) {
        require(
            index < auctions.length,
            "unknown auction"
        );

        Auction memory auction = auctions[index];
        uint elapsed = block.timestamp - auction.startAt;
        uint discout = auction.discountRate * elapsed;

        return auction.startPrice - discout;
    }

    function buy(uint index) external payable {
        require(
            index < auctions.length,
            "unknown auction"
        );

        Auction memory auction = auctions[index];

        require(
            !auction.stopped,
            "auction is over"
        );

        require(
            block.timestamp < auction.endAt,
            "time is over"
        );

        uint currentPrice = getPrice(index);

        require(
            msg.value >= currentPrice,
            "not enough funds"
        );

        auction.stopped = true;
        auction.finalPrice = currentPrice;

        // send if received more money
        uint refund = msg.value - currentPrice;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }

        // send seller funds
        auction.seller.transfer(currentPrice - (currentPrice * FEE) / 100);

        emit AuctionEnded(index, msg.sender, auction.finalPrice);
    }
}


