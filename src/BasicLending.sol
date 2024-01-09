// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BasicLending {
    error InsufficientETH();
    error TransferFailed();
    error RepaymentExceedsDebt();

    mapping(address => uint256) private balances;
    mapping(address => uint256) private borrowedBalances;

    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed from, uint256 amount);
    event Borrow(address indexed from, uint256 amount);
    event Repay(address indexed from, uint256 amount);
    event FullyRepaidLoan(address indexed from);

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public {
        if (_amount > balances[msg.sender]) revert InsufficientETH();
        balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        if (!success) revert TransferFailed();
        emit Withdraw(msg.sender, _amount);
    }

    function borrow(uint256 _amount) public {
        if (_amount > address(this).balance) revert InsufficientETH();
        borrowedBalances[msg.sender] += _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        if (!success) revert TransferFailed();
        emit Borrow(msg.sender, _amount);
    }

    function repay() public payable {
        if (msg.value > borrowedBalances[msg.sender])
            revert RepaymentExceedsDebt();
        borrowedBalances[msg.sender] -= msg.value;
        emit Repay(msg.sender, msg.value);
        if (borrowedBalances[msg.sender] == 0) emit FullyRepaidLoan(msg.sender);
    }

    function getBalance(address _user) external view returns (uint256) {
        return balances[_user];
    }

    function getBorrowedBalance(address _user) external view returns (uint256) {
        return borrowedBalances[_user];
    }
}
