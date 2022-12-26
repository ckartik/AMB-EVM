// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

// This contract will be deployed on both chains
// We maintain the AMB to take in arbitray input for it's calldata.
// TODO(@ckartik): Make amb payable with a min fee.
interface IAMB {
    // Core implementation
    function send(address recipient, bytes calldata data) payable external;
    function receive(address recipientContract, bytes calldata data) external;
}


// TODO(@ckartik): Emit events as well during additions to the queue
contract Counter {
    IAMB AMB;
    address sendingCounter;
    address receivingCounter;
    address public owner;
    uint256 counter;
    uint minFee;

    constructor(IAMB _amb) {
       counter = 0;
       AMB = _amb;
       owner = msg.sender;
       minFee = 25 gwei;
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    function getCount() public view returns (uint) {
        return counter;
    }

    function setSendingCounter(address _sendingCounter) public onlyOwner { 
        sendingCounter = _sendingCounter;
    }
    
    function setReceivingCounter(address _receivingCounter) public onlyOwner {
       receivingCounter = _receivingCounter;
    }

    // Send leverages the AMB to send an encoded & signed call cross-chain 
    // to increment a counter contract on the corresponding chain
    //
    // TODO(@ckartik): Possibly verify signature at the recieiving ABI?
    function send() public payable { 
        require(msg.value >= minFee, "MIN_FEE_NOT_SATISFIED");
        AMB.send{ value: minFee }(receivingCounter, abi.encodeWithSignature("increment()"));
    }


    // Design Decision: I've decided to avoid 
    function increment() public {
        console.log("Counter at %s is being incremented by %s", address(this), msg.sender);
        // require(msg.sender == address(AMB) || msg.sender == owner, "UNIDENTIFIED_SENDER");
        counter++;
    }
}
