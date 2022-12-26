// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

interface IAMB {
    function send(address recipient, bytes calldata data) payable external;
    function receive(address recipientContract, bytes calldata data) external;
}

contract Counter {
    IAMB AMB;
    address receivingCounter;
    address public owner;
    uint256 counter;
    uint minFee;

    constructor(IAMB _amb) {
       counter = 0;
       AMB = _amb;
       owner = msg.sender;
       minFee = 0.0002 ether;
    }
    event NotifyRelayer(uint);

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    function getCount() public view returns (uint) {
        return counter;
    }
    
    // setReceivingCounter is used to initalize the address of the corresponding counter
    // to be incremented through the AMB interface
    function setReceivingCounter(address _receivingCounter) public onlyOwner {
       receivingCounter = _receivingCounter;
    }

    // Send leverages the AMB to send an encoded & signed call cross-chain 
    // to increment a counter contract on the corresponding chain
    function send() public payable { 
        require(msg.value >= minFee, "MIN_FEE_NOT_SATISFIED");
        AMB.send{ value: minFee }(receivingCounter, abi.encodeWithSignature("increment()"));
    }


    // Design Decision: I've decided to avoid validation on this call.
    // TO add validation such that only a AMB or contract owner can increment we
    // can simply add the following require statment:
    // require(msg.sender == address(AMB) || msg.sender == owner, "UNIDENTIFIED_SENDER");
    function increment() public {
        counter++;
    }
}
