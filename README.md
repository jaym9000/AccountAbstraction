# About

This repository contains a basic implementation of Account Abstraction (AA) on Ethereum and zkSync. The goal is to demonstrate how to deploy and interact with smart contracts using user operations.

## Features

1. Create a basic AA on Ethereum
2. Create a basic AA on zkSync
3. Deploy and send a user operation (userOp) or transaction through them
   - Not going to send an AA to Ethereum
   - But we will send an AA transaction to zkSync

## Testing

The project includes a suite of tests to ensure the functionality of the MinimalAccount contract. The tests are written in Solidity and utilize the Forge testing framework.

### Test Cases

- **Owner Command Execution**: Tests that the owner of the MinimalAccount can successfully execute commands.
- **Non-Owner Command Restriction**: Tests that a non-owner cannot execute commands.
- **User Operation Recovery**: Tests the recovery of signed user operations.
- **User Operation Validation**: Tests the validation of user operations.
- **Entry Point Command Execution**: Tests that commands can be executed through the entry point.

## Setup

To set up the project, ensure you have the following prerequisites:

- [Foundry](https://book.getfoundry.sh/) for Solidity development and testing.
- Node.js and npm for managing dependencies.

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Build the project:
   ```bash
   forge build
   ```

## Running Tests

To run the tests, use the following command:
```bash
forge test --mt testEntryPointCanExecuteCommands -vvv
```

This will execute the tests and provide verbose output.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.