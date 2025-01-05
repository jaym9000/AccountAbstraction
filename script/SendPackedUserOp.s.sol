// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {HelperConfig} from "./HelperConfig.s.sol";
import {Script} from "forge-std/Script.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";

contract DeployMinimal is Script, HelperConfig {
    function deployMinimalAccount() public {
        // MinimalAccount minimalAccount = new MinimalAccount(address(this));
    }
}
