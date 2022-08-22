#### what is zero-account?

> If the target account is not set (the transaction does not have a recipient or the recipient is set to null), the transaction creates a new contract. As already mentioned, the address of that contract is not the zero address but an address derived from the sender and its number of transactions sent (the “nonce”). The payload of such a contract creation transaction is taken to be EVM bytecode and executed. The output data of this execution is permanently stored as the code of the contract. This means that in order to create a contract, you do not send the actual code of the contract, but in fact code that returns that code when executed.

- from [solidity - Transactions](https://docs.soliditylang.org/en/develop/introduction-to-smart-contracts.html?highlight=address(0)#index-8)


> Within an Ethereum transaction, the zero-account is just a special case used to indicate that a new contract is being deployed. It is literally '0x0' set to the to field in the raw transaction. 
> 
> Every Ethereum transaction, whether it's a transfer between two external accounts, a request to execute contract code, or a request to deploy a new contract, are encoded in the same way. A raw transaction object will look something like this:
```javascript
transaction = {
nonce: '0x0',
gasLimit: '0x6acfc0', // 7000000
gasPrice: '0x4a817c800', // 20000000000
to: '0x0',
value: '0x0',
data: '0xfffff'
};
```
> If to is set to something other than '0x0', this request will result in transferring ether to the address (if value is non-zero), and execute the function encoded in the data field. Remember, the address can either be a contract or an external account.

> When the to address is the zero-address, a new contract will be created by executing the code in data (this is what is meant by "code that returns the code"). The address of the newly created contract is technically known beforehand as it's based on the address of the sender and it's current nonce. That address becomes the official address of the contract after mining.

> For a pretty good read on Ethereum transactions, check out this [blog post](https://medium.com/@codetractio/inside-an-ethereum-transaction-fa94ffca912f).

> **Note: There is also the actual Solidity code statement address(0) which is the initial value of a variable of type address. The documentation up there, however, is referring to specifically when the to account address in a transaction is set to '0x0'.**

- from [stackoverflow](https://stackoverflow.com/questions/48219716/what-is-address0-in-solidity)

