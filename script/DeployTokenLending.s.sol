// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {LendingToken} from "../src/LendingToken.sol";
import {TokenLending} from "../src/TokenLending.sol";

contract DeployTokenLending is Script {
    function run() external returns (TokenLending) {
        vm.startBroadcast();
        LendingToken lendingToken = new LendingToken();
        TokenLending tokenLending = new TokenLending(address(lendingToken));
        vm.stopBroadcast();
        return tokenLending;
    }
}
