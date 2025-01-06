// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "../../src/ethereum/MinimalAccount.sol";
import {DeployMinimal} from "../../script/DeployMinimal.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

/// @title MinimalAccountTest
/// @author JM
/// @notice Tests for the MinimalAccount contract
/// @dev This contract contains unit tests to verify the functionality of the MinimalAccount contract
contract MinimalAccountTest is Test {
    HelperConfig helperConfig;  // Configuration helper for deployment
    MinimalAccount minimalAccount;  // Instance of the MinimalAccount contract
    ERC20Mock usdc;  // Mock ERC20 token for testing

    address randomuser = makeAddr("randomUser");  // Address for a non-owner user
    uint256 constant AMOUNT = 1e18;  // Amount to be used in tests

    /// @notice Sets up the test environment
    /// @dev Deploys the MinimalAccount and ERC20Mock contracts before each test
    function setUp() public {
        DeployMinimal deployMinimal = new DeployMinimal();
        (helperConfig, minimalAccount) = deployMinimal.deployMinimalAccount();
        usdc = new ERC20Mock();
    }

    /// @notice Tests that the owner can execute commands
    /// @dev This test verifies that the owner of the MinimalAccount can successfully execute a command
    function testOwnerCanExecuteCommands() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            AMOUNT
        );

        // Act
        vm.prank(minimalAccount.owner());
        minimalAccount.execute(dest, value, functionData);

        // Assert
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }

    /// @notice Tests that a non-owner cannot execute commands
    /// @dev This test verifies that a user who is not the owner cannot execute a command
    function testNonOwnerCannotExecuteCommands() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(minimalAccount),
            AMOUNT
        );

        // Act
        vm.prank(randomuser);
        vm.expectRevert(
            MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector
        );
        minimalAccount.execute(dest, value, functionData);
    }
}