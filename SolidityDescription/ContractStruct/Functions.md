Functions are usually defined inside a contract, but the can also be defined outside of contracts.

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.16;
contract ContractDemo {
    function foo(bool success) external view returns (uint amount) {
        require(success, "Not success");
        return amount;
    }
}
```

Functions in solidity have the following form:
```
function <function_name>(<param_type> <param_name>) <visibility> <state_mutability> [(modifiers)] [returns <return_types>] { ... }
```
- `visibility`: `internal`|`external`|`public`|`private`
  - `internal`: those functions and state variables can only be accessed internally, without using `this`.
  - `external`: the function can only be called from **outside** the contract.An `external` function `f` cannot be called internally(i.e. `f()` does not work, but `this.f()` works).
  - `public`: public functions can be either called internally or via messages.
  - `private`: those functions and variables are only visible for the contract the defined in and not in derived contracts
- `state_mutability`: `pure`|`view`|`payable`
  - `pure`: functions declared with `pure` can neither read nor modify the state variables. Can only use local variables that are declared in the function and the arguments that are passed to the function to compute or return a value.
  - `view`: can read state, but do not be allowed to modify state.
  - `payable`: Can accept Ether sent to the contract, if it's not specified, the function will automatically reject all Ether sent to it.

Addition reading:
- [`public` vs `external`](https://ethereum.stackexchange.com/questions/19380/external-vs-public-best-practices)
- [What are pure functions in Solidity?](https://www.educative.io/answers/what-are-pure-functions-in-solidity)
- [function-definition](https://docs.soliditylang.org/en/v0.8.16/grammar.html#a4.SolidityParser.functionDefinition)
