// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// 为每个（投票）表决创建一份合约
// 为每个选项提供简称
// 作为合约的创造者——即主席，将给予每个独立的地址以投票权
// 地址后面的人可以选择自己投票，或者委托给他们信任的人来投票
contract Ballot {
    // 一个选民
    struct Voter {
        uint weight; // 计票的权重
        bool voted; // 是否已投票
        address delegate; // 被委托投票人
        uint vote; // 投票提案的索引
    }

    // 提案类型
    struct Proposal {
        bytes32 name; // 简称（最长32个字节）
        uint voteCount;// 得票数
    }

    address public chairperson;

    // 声明一个状态变量，为每个可能的地址存储一个`Voter`
    mapping(address => Voter) public voters;

    // `Proposal`类型的动态数组
    Proposal[] public proposals;

    // 为`proposalNames`中的每个提案创建一个新的（投票）表决
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender; // chairperson即为创建合约者
        voters[chairperson].weight = 1;
        // 对于提供的每个提案名称，
        // 创建一个新的`Proposal`对象并把它添加到数据的末尾
        for (uint i = 0; i < proposalNames.length; i++) {
            // `Proposal({...})`创建一个临时Proposal对象
            // `push`将其添加到`proposals`末尾
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // 授权`voter`对这个（投票）表决进行投票
    // 只有`chairperson`可以调用该函数
    function giveRightToVote(address voter) external {
        // 若`require`的第一个参数为`false`，则中止执行，撤销所有对状态和以太币余额的改动
        // 使用`require`来检查函数是否被正确的调用，是一个好习惯
        // `require`第二个参数提供了一个对错误情况的解释

        // 需要 合约创建者是`chairperson`
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    // 委托
    // 把投票权利委托到投票者`to`
    function delegate(address to) external {
        // 传递引用
        Voter storage sender = voters[msg.sender];
        // 创建合约者没有投过票
        require(!sender.voted, "You already voted.");

        // 委托人不能与创建合约者为同一人
        require(to != msg.sender, "Self-delegation is disallowed.");

        // 委托是可以传递的，只要被委托者`to`也设置了委托。
        // 一般来说，这种循环委托是危险的。因为，如果传递的链条太长，则可能需要消耗的gas要多于区块中剩余的
        // 即大于许快设置的gasLimit，
        // 这种情况下，委托不会被执行。
        // 而在另外一些情况下，如果形成闭环，则会让合约完全卡住
        while (voters[to].delegate != address(0)) {
            // `to`是一个`address`，是众多`voters`中的一个
            to = voters[to].delegate;

            // 不允许闭环委托，即不允许委托者`to`是创建合约者`msg.sender`
            require(to != msg.sender, "Found loop in delegation.");
        }

        // 创建一个`voters[to]`的引用
        Voter storage delegate_ = voters[to];

        require(delegate_.weight >= 1);

        // `sender`是一个引用，相当于对`voters[msg.sender].voted`进行修改
        sender.voted = true;
        sender.delegate = to;

        if (delegate_.voted) {
            // 若被委托者已经投过票了，直接增加得票数
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // 若被委托者还没投票，增加委托者权重
            delegate_.weight += sender.weight;
        }
    }

    // 投票（包括委托给你的票）
    // 投给提案`proposals[proposal].name`
    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // 如果`proposal`超过了数组的范围，则会自动抛出一场，并回复所有的改动
        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() external view returns (uint winningProposalIndex) {
        uint winningVoteCount = 0;
        uint tempWinningProposalIndex = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                tempWinningProposalIndex = p;
            }
        }
        winningProposalIndex = tempWinningProposalIndex;
    }

    function winnerName() public view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
}
