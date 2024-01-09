// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {TokenLending} from "../src/TokenLending.sol";
import {LendingToken} from "../src/LendingToken.sol";
import {DeployTokenLending} from "../script/DeployTokenLending.s.sol";

contract BasicLendingTest is Test {
    TokenLending tokenLending;
    LendingToken token;

    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 1000 * 10 ** 18;
    uint256 constant SEND_VALUE = 100 * 10 ** 18;

    function setUp() external {
        DeployTokenLending deployTokenLending = new DeployTokenLending();
        (tokenLending, token) = deployTokenLending.run();

        token.mint(USER, STARTING_BALANCE);
        vm.prank(USER);
        token.approve(address(tokenLending), SEND_VALUE);
    }

    function testUserCanDepositTokens() public {
        vm.prank(USER);
        tokenLending.depositToken(SEND_VALUE);
        assertEq(tokenLending.getBalance(USER), SEND_VALUE);
    }
}
