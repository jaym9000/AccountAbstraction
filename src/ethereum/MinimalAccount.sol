// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

/// @title MinimalAccount
/// @author JM
/// @notice A minimal implementation of ERC-4337 compatible smart contract wallet
/// @dev Implements core ERC-4337 account functionality with basic signature validation
contract MinimalAccount is IAccount, Ownable {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error MinimalAccount__NotFromEntryPoint();
    error MinimalAccount__NotFromEntryPointOrOwner();
    error MinimalAccount__CallFailed(bytes);
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    IEntryPoint private immutable i_entryPoint;

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Ensures the function caller is the EntryPoint
    /// @dev Reverts if msg.sender is not the EntryPoint contract
    modifier requireFromEntryPoint() {
        if (msg.sender != address(i_entryPoint)) {
            revert MinimalAccount__NotFromEntryPoint();
        }
        _;
    }

    /// @notice Ensures the function caller is either the EntryPoint or the account owner
    /// @dev Reverts if msg.sender is neither the EntryPoint nor the owner
    modifier requireFromEntryPointOrOwner() {
        if (msg.sender != address(i_entryPoint) && msg.sender != owner()) {
            revert MinimalAccount__NotFromEntryPointOrOwner();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    receive() external payable {}

    /// @notice Constructs a new MinimalAccount
    /// @param entryPoint The address of the ERC-4337 EntryPoint contract
    /// @dev Sets the owner to the msg.sender and initializes the EntryPoint reference
    constructor(address entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(entryPoint);
    }

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Executes a transaction from the account
    /// @param dest The target address for the transaction
    /// @param value The amount of ETH to send
    /// @param functionData The data to pass to the target address
    /// @dev Can only be called by the EntryPoint
    function execute(
        address dest,
        uint256 value,
        bytes calldata functionData
    ) external payable requireFromEntryPoint {
        (bool success, bytes memory result) = dest.call{value: value}(
            functionData
        );
        if (!success) {
            revert MinimalAccount__CallFailed(result);
        }
    }

    /// @notice Validates the signature of a UserOperation
    /// @param userOp The UserOperation to validate
    /// @param userOpHash The hash of the UserOperation
    /// @param missingAccountFunds The funds needed to be paid to the EntryPoint
    /// @return validationData Packed validation data (see ERC-4337 specs)
    /// @dev Implements signature validation and handles the payment of fees
    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external requireFromEntryPoint returns (uint256 validationData) {
        _validateSignature(userOp, userOpHash);
        _payPrefund(missingAccountFunds);
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Validates the signature of a UserOperation
    /// @param userOp The UserOperation to validate
    /// @param userOpHash The hash of the UserOperation
    /// @return validationData 0 if signature is valid, 1 if invalid
    /// @dev Uses EIP-191 for signature verification
    function _validateSignature(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) internal view returns (uint256 validationData) {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(
            userOpHash
        );
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);
        if (signer != owner()) {
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_SUCCESS;
    }

    /// @notice Pays the required prefund to the EntryPoint
    /// @param missingAccountFunds The amount of funds needed
    /// @dev Transfers the required funds to the EntryPoint if needed
    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds > 0) {
            (bool success, ) = payable(msg.sender).call{
                value: missingAccountFunds,
                gas: type(uint256).max
            }("");
            (success);
        }
    }

    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the address of the EntryPoint contract
    /// @return The address of the EntryPoint contract
    function getEntryPoint() external view returns (address) {
        return address(i_entryPoint);
    }
}
