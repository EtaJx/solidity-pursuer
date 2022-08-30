#### State Variables

- State Variables: variables whose values are permanently stored in contract storage.
    ```solidity
    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.16;
    contract ContractDemo {
        uint stateVariable;  // this is state varibale
    }
    ```
- Local Variables: variables whose values are present till function is executing.
    ```solidity
    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.16;
    contract ContractDemo {
        function foo() external view return (bool) {
            uinit a = 1; // local variable
            return true;
        }
    }
    ```

#### [Data Location](https://docs.soliditylang.org/en/v0.8.16/types.html#data-location)

- `memory`: just like the keyword `memory`. variables stored in memory. In solidity, to be stored in memory a variable has to be defined inside a function. These variables will be destroyed once the function has completed.
- `storage`: where all state variables are stored. These variables defined as storage is written to the blockchain. (How about a constant state variable?)
- `calldata`: `calldata` is immutable, temlorary location where function arguments are stored, and behaves mostly like `memory`. `calldata` is only valid for parameters of external contract functions.
