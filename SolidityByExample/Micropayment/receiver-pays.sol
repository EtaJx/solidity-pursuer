// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract ReceiverPays {
  address owner = msg.sender;

  mapping(uint256 => bool) usedNonces;

  constructor() payable {}

  // 收款方认领付款
  // 重放攻击：一个被授予的支付消息被重复使用
  // 为了避免重放攻击，引入一个`nonce`（以太坊链上交易也是使用这个方式来防止重放攻击），
  // 它表示一个账号已经发送交易的次数。
  // 智能合约将检查nonce是否使用过。

  // 还有一种重放攻击攻击的可能：
  // 所有者部署`ReceiverPays`之后，进行了一些支付，然后销毁合约，重新部署合约，这时新的合约无法知道先前部署合约的nonce
  // 可以通过在签名信息中加入合约地址来阻止这个攻击
  function claimPayment(uint256 amount, uint256 nonce, bytes memory signature) external {
    // 防止重放攻击，确保nonce是未被使用的
    require(!usedNonces[nonce]);
    usedNonces[nonce] = true;

    bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, this)));

    require(recoverSigner(message, signature) == owner);

    payable(msg.sender).transfer(amount);
  }

  function kill() external {
    require(msg.sender == owner);
    selfdestruct(payable(msg.sender));
  }

  // 提取签名参数
  // 签名是使用web3.js签名的数据
  // r, s, v都是链接在一起的，需要将他们分离出来
  function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
    require(sig.length == 65);

    // 使用内联汇编完成分离工作
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    return (v, r, s);
  }

  // 还原消息签名者
  // 在ECDSA（椭圆曲线数字签名算法）包含两个参数：r,s
  // 在以太坊中签名包含第三个参数：v，用于验证哪一个账号的私钥签署了这个消息
  // 使用内建函数`ecrecover`接收`r`, `s,`, `v`作为参数并返回签名这的地址
  function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
    (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
    return ecrecover(message, v, r, s);
  }

  function prefixed(bytes32 hash) internal pure returns(bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }

}
