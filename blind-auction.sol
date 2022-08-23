// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract BlindAuction {
    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

    // 收益者
    address payable public beneficiary;
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;

    mapping(address => Bid[]) public bids;

    address public highestBidder;
    uint public highestBid;

    // 允许撤销之前的出价
    mapping(address => uint) pendingReturns;

    event AuctionEnded(address winner, uint highestBid);

    error TooEarly(uint time);
    error TooLate(uint time);
    error AuctionEndAlreadyCalled();

    // `modifier`修改器
    // 修改器是一个很方便的验证函数输入的方法
    // `onlyBefore`被用于`bid`函数：
    // 新的函数体是由`modifier`的函数体，并且`_`替换原函数体语句来组成
    modifier onlyBefore(uint time) {
        if (block.timestamp >= time) revert TooLate(time);
        _;
    }
    modifier onlyAfter(uint time) {
        if (block.timestamp <= time) revert TooEarly(time);
        _;
    }

    constructor(
        uint biddingTime,
        uint revealTime,
        address payable beneficiaryAddress
    ) {
        beneficiary = beneficiaryAddress;
        biddingEnd = block.timestamp + biddingTime;
        revealEnd = biddingEnd + revealTime;
    }

    // 可以通过`blindedBid = keccak256(value, fake, secret)`
    // 来设置一个秘密竞拍
    // 只有在出价披露阶段被正确披露，已发送的以太币才会被退还
    // 如果与出价一起发送的以太币至少为`value`且`fake`不为真，则出价有效
    // 将`fake`设置为true，然后发送满足订金金额但又不与出价相同的金额是隐藏实际出价的方法
    // 同一个地址可以放置多个出价
    function bid(bytes32 blindedBid) external payable onlyBefore(biddingEnd) {
        bids[msg.sender].push(Bid({
            blindedBid: blindedBid,
            deposit: msg.value
        }));
    }

    // 披露秘密竞拍出价
    // 对于所有正确披露的无效出价以及除最高出价意外的所有出价，都将获得退款
    function reveal(
        uint[] calldata values,
        bool[] calldata fakes,
        bytes32[] calldata secrets
    )
        external
        onlyAfter(biddingEnd)
        onlyBefore(revealEnd)
    {
        uint length = bids[msg.sender].length;
        require(values.length == length);
        require(fakes.length == length);
        require(secrets.length == length);

        uint refund;

        for (uint i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i];
            (uint value, bool fake, bytes32 secret) = (values[i], fakes[i], secrets[i]);

            if (bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake, secret))) {
                continue;
            }

            refund += bidToCheck.deposit;
            if (!fake && bidToCheck.deposit >= value) {
                if (placeBid(msg.sender, value))
                    refund -= value;
            }

            bidToCheck.blindedBid = bytes32(0);
        }
        payable(msg.sender).transfer(refund);
    }

    function withdraw() external {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

    function auctionEnd() external onlyAfter(revealEnd) {
        if (ended) revert AuctionEndAlreadyCalled();
        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(highestBid);
    }

    // `internal`函数表示该函数只能在本合约（或继承合约）内被调用
    function placeBid(address bidder, uint value) internal returns (bool success) {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }
}
