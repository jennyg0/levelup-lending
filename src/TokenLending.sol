// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenLending {
    error InsufficientAllowance();
    error InsufficientBalance();
    error OverRepayment();
    error TransferFailed();

    IERC20 private token;
    mapping(address => uint256) private balances;
    mapping(address => uint256) private borrowed;

    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed from, uint256 amount);
    event Borrow(address indexed from, uint256 amount);
    event Repay(address indexed from, uint256 amount);
    event FullyRepaidLoan(address indexed from);

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    modifier checkAllowance(uint256 _amount) {
        if (token.allowance(msg.sender, address(this)) < _amount)
            revert InsufficientAllowance();
        _;
    }

    function depositToken(uint256 _amount) public checkAllowance(_amount) {
        balances[msg.sender] += _amount;
        bool success = token.transferFrom(msg.sender, address(this), _amount);
        if (!success) revert TransferFailed();
        emit Deposit(msg.sender, _amount);
    }

    function withdrawToken(uint256 _amount) public {
        if (balances[msg.sender] < _amount) revert InsufficientBalance();
        balances[msg.sender] -= _amount;
        bool success = token.transfer(msg.sender, _amount);
        if (!success) revert TransferFailed();
        emit Withdraw(msg.sender, _amount);
    }

    function borrowToken(uint256 _amount) public {
        if (token.balanceOf(address(this)) < _amount)
            revert InsufficientBalance();
        borrowed[msg.sender] += _amount;
        bool success = token.transfer(msg.sender, _amount);
        if (!success) revert TransferFailed();
        emit Borrow(msg.sender, _amount);
    }

    function repayToken(uint256 _amount) public checkAllowance(_amount) {
        if (borrowed[msg.sender] < _amount) revert OverRepayment();
        borrowed[msg.sender] -= _amount;
        bool success = token.transferFrom(msg.sender, address(this), _amount);
        if (!success) revert TransferFailed();
        if (borrowed[msg.sender] == 0) {
            emit FullyRepaidLoan(msg.sender);
        } else {
            emit Repay(msg.sender, _amount);
        }
    }

    function getBalance(address _user) external view returns (uint256) {
        return balances[_user];
    }
}
