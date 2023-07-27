// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Store {
    struct payments {
        uint256 amount;
        uint256 finalAmount;
        uint256 initialAmount;
        uint8 paymentType;
        bool valid;
        bool checked;
        address sender;
        address receiver;
    }

    uint256 public number;
    mapping(address => uint256) balances;
    payments[8] topPayments;
    address admin;
    address admin2;
    bool flag1;
    bool flag2;
    bool flag3;
    uint8 index;

    constructor() {}

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
