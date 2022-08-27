- [SPDX License Identifier](https://spdx.org): Every source file should start with a comment indicating its license: `// SPDX-License-Identifier: MIT`
- `pragma` key word: use to enable certain compiler features ot checks and a pragma directive is always local to a source file
  - Version Pragma: source file can (and should) be annotated with a version `pragma` to reject compilation with future compiler versions that might introduce incompatible changes.

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.16;
contract Demo {
    // contract code
}
```
