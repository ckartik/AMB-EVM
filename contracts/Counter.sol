// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// This contract will be deployed on both chains
// We maintain the AMB to take in arbitray input for it's calldata.
// TODO(@ckartik): Make amb payable with a min fee.
interface IAMB {
    // Core implementation
    function send(address recipient, bytes calldata data) external;
    function receive(address recipientContract, bytes calldata data) external;
}

contract Counter {
    IAMB AMB;
    address sendingCounter;
    address receivingCounter;
    address public owner;
    uint256 counter;

    constructor(IAMB _amb, address _sendingCounter, address _receivingCounter) {
       counter = 0;
       AMB = _amb;
       owner = msg.sender
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    function send() public { 
        AMB.send(receivingCounter, abi.encodeWithSignature("increment()"));
    }

    function setSendingCounter(address _sendingCounter) public onlyOwner { 
        sendingCounter = _sendingCounter;

    }
    
    function setReceivingCounter(address _receivingCounter) public onlyOwner {
       receivingCounter = _receivingCounter;
    }

    function getSendingCounter() public view returns (address) {
        return sendingCounter;
    }

    function getCount() public view returns (uint) {
        return counter;
    }

    function increment() public {
        require(msg.sender == address(AMB), "UNIDENTIFIED_SENDER");
        counter++;
    }
}
