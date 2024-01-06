// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {BasicLending} from "../src/BasicLending.sol";

// import {DeployBasicLending} from "../script/DeployBasicLending.s.sol";

contract DeployBasicLending is Script {
    function run() external returns (BasicLending) {
        vm.startBroadcast();
        BasicLending basicLending = new BasicLending();
        vm.stopBroadcast();
        return basicLending;
    }
}
