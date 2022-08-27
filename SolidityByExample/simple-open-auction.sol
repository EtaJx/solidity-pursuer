// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract SimpleOpenAuction {
    address payable public beneficiary;
    // 拍卖结束时间：以unix的绝对时间戳（自1970-01-01以来的秒数）
    // 或以秒为单位的时间段
    uint public auctionEndTime;
    // 最高出价者
    address public highestBidder;
    // 最高出价
    uint public highestBid;

    // 允许撤回的之前的出价
    mapping(address => uint) pendingReturns;

    // 设置为`true`后，禁止所有变更
    // 默认值为`false`
    bool ended;

    // 在变化的时候执行的事件
    // 1. 增加最高出价
    event HighestBidIncreased(address bidder, uint amount);
    // 2. 拍卖结束
    event AuctionEnded(address winner, uint amount);

    // 用来描述失败的错误 (Errors)
    error AuctionAlreadyEnded();
    error BidNotHighEnough(uint highestBid);
    error AuctionNotYetEnded();
    error AuctionEndAlreadyCalled();

    // 以受益者地址`beneficiaryAddress`创建一个持续`biddingTime`秒的拍卖
    constructor(uint biddingTime, address payable beneficiaryAddress) {
        beneficiary = beneficiaryAddress;
        auctionEnd = block.timestamp + biddingTime;
    }

    // 出价
    // 具体的出价将会随交易一起发送
    // 如果没有在拍卖中胜出，则返还出价
    function bid() external payable {
        // 如果拍卖已结束，执行`revert`
        if (block.timestamp > auctionEndTime) {
            revert AuctionAlreadyEnded();
        }
        // 如果出价小于目前最高出价，则返还出价
        if (msg.value <= highestBid)
            revert BidNotHighEnough(highestBid);

        //
        if (highestBid != 0) {
            // 返还出价时，简单调用`highestBidder.sender(highestBid)`函数是有安全风险的，
            // 因为它有可能执行一个非信任合约
            // 更为安全的做法是让接收方自己提取金钱
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    // 撤回出价（当该出价已经被超越时）
    function withdraw() external returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0 ) {
            // 这里设置零值很重要
            // 因为作为接收调用的一部分
            // 接收者可以在`send`返回之前，重新调用该函数
            pendingReturns[msg.sender] = 0;
        }
        // 如果`msg.sender`不是`address payable`的类型
        // 需要进行一次显示转换（类型转换？）来使用`send()`成员函数
        // must be explicitly converted using `payable(msg.sender)` in order
        // use the member function `send()`
        if (!payable(msg.sender).send(amount)) {
            // 不需要抛出异常，只需重置未付款
            pendingReturns[msg.sender] = amount;
            return false;
        }
        return true;
    }

    // 结束拍卖, 并把最高出价发送给受益人
    function auctionEnd() external {
        // 对于可与其他合约交互的函数（意味着它会调用其他函数或发送以太币），
        // 一个好的指导方针是将其结构分为三个阶段：
        // 1. 检查条件
        // 2. 执行动作（可能会改变条件）
        // 3. 与其他合约交互
        // 如果这些阶段相混合，其他的合约可能会回调当前合约并修改状态，
        // 或者导致某些效果（比如支付以太币）多次生效。
        // 如果合约内调用的函数包含了与外部合约的交互，
        // 则它也会被认为是与外部合约有交互的。

        // 1. 条件
        if (block.timestamp < auctionEndTime) {
            revert AuctionNotYetEnded();
        }
        if (ended) {
            revert AuctionEndAlreadyCalled();
        }

        // 2. 生效
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        // 3. 交互
        beneficiary.transfer(highestBid);
    }
}
