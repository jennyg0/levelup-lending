// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {BasicLending} from "../src/BasicLending.sol";
import {DeployBasicLending} from "../script/DeployBasicLending.s.sol";

contract BasicLendingTest is Test {
    BasicLending basicLending;

    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;

    function setUp() external {
        DeployBasicLending deployBasicLending = new DeployBasicLending();
        basicLending = deployBasicLending.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanDepositFunds() public {
        vm.prank(USER);
        basicLending.deposit{value: SEND_VALUE}();
        assertEq(basicLending.getBalance(USER), SEND_VALUE);
    }

    function testUserCannotWithdrawFundsIfNotEnough() public {
        vm.prank(USER);
        vm.expectRevert(BasicLending.InsufficientETH.selector);
        basicLending.withdraw(1);
    }

    function testUserCanWithdrawFunds() public {
        vm.prank(USER);
        basicLending.deposit{value: SEND_VALUE}();
        vm.prank(USER);
        basicLending.withdraw(SEND_VALUE);
        assertEq(USER.balance, STARTING_BALANCE);
    }

    function testUserCanBorrowFunds() public {
        basicLending.deposit{value: SEND_VALUE}();
        vm.prank(USER);
        basicLending.borrow(SEND_VALUE);
        assertEq(basicLending.getBorrowedBalance(USER), SEND_VALUE);
    }

    function testUserCannotBorrowFundsIfNoneInContract() public {
        vm.prank(USER);
        vm.expectRevert(BasicLending.InsufficientETH.selector);
        basicLending.borrow(SEND_VALUE);
    }

    function testUserCannotRepayTooMuch() public {
        vm.prank(USER);
        vm.expectRevert(BasicLending.RepaymentExceedsDebt.selector);
        basicLending.repay{value: SEND_VALUE}();
    }

    function testRepayFunctionFullRepayment() public {
        basicLending.deposit{value: SEND_VALUE}();
        vm.prank(USER);
        basicLending.borrow(SEND_VALUE);
        vm.prank(USER);
        basicLending.repay{value: SEND_VALUE}();
        assertEq(basicLending.getBorrowedBalance(USER), 0);
    }

    function testRepayFunctionPartialRepayment() public {
        basicLending.deposit{value: SEND_VALUE * 2}();
        vm.prank(USER);
        basicLending.borrow(SEND_VALUE * 2);
        vm.prank(USER);
        basicLending.repay{value: SEND_VALUE}();
        assertEq(basicLending.getBorrowedBalance(USER), SEND_VALUE);
    }
}
