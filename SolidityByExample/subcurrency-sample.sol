// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

// 合约名称`Coin`
contract Coin {
    // 关键词`public`自动生成一个函数，允许你再这个合约之外访问这个状态变量的当前值
    // `address` 类型是一个160位值，且不允许任何算数操作
    // 这种类型是个存储合约地址或者外部人员的密钥对
    // `public`由编译器生成的函数代码大致如下：
    // ```solidity
    // function minter() external view returns (address) { return minter; }
    // ```
    address public minter;
    mapping (address => uint) public balances;

    // 声明 事件 Event
    // 轻客户端可以通过事件针对变化做出高效的反应
    // 这个事件会在`send`函数最后一行发出
    // 用户界面（服务器应用程序）可以舰艇区块链上正在发送的事件
    // 一旦该事件被发出，监听它的所有listener都会收到通知
    // 所有的事件都包含`from`, `to`, `amount`三个参数
    event Sent(address from, address to, uint amount);

    // 构造函数，只有当合约创建时运行
    // 在该合约中，构造函数永久存储创建合约的人的地址：msg —— 一个特殊的全局变量
    // 特殊的全局变量还包括`tx`和`block`
    // 这些特殊的全局变量允许我们访问区块链的属性
    // `msg.sender`始终记录当前（外部）函数调用是来自于哪一个地址
    constructor() {
        minter = msg.sender;
    }

    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        balances[receiver] += amount;
    }

    // Errors allow you to provide information about
    // why an operation failed. They are returned
    // to the caller of the function.
    // Errors用来向调用者描述错误信息
    error InsufficientBalance(uint requested, uint available);

    function send(address receiver, uint amount) public {
        if (amount > balances[msg.sender])
            // Error与revert语句一起使用
            // revert语句无条件的中止执行并回退所有的变化
            revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}
