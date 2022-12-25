// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Counter {
    uint public count;

    constructor() {
       count = 0;
    }

    function getCount() public view returns (uint) {
        return count;
    }

    function increment() public {
        count += 1;
    }
}
