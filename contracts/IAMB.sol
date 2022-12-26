// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

// TODO:(@ckartik): Implement


struct Message {
    address sender;
    address reciever;
    bytes callData;
}

interface IAMB {
    // Core implementation
    function send(address recipient, bytes calldata data) external;
    function receive(address recipientContract, bytes calldata data) external;
}

 // TODO(@ckartik): Make amb payable with a min fee
 // TODO(@ckartik): Owner should be able to set Trusted Relayer arbitrarily
contract AMB {
    address TRUSTED_RELAYER;
    address OWNER;
    uint minFee;
    uint payment;
    Message[] queue; 

    constructor() { 
       TRUSTED_RELAYER = msg.sender;
       OWNER = msg.sender;
       minFee = 25 gwei;
       payment = 20 gwei;
    }

    modifier onlyRelayer() {
        require(msg.sender == TRUSTED_RELAYER, "NOT_TRUSTED_RELAYER");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == OWNER, "NOT_OWNER");
        _;
    }

    function getQueue() public view returns (Message[] memory) {
        return queue;
    }

    function setNewRelayer(address newRelayer) public onlyOwner {
        TRUSTED_RELAYER = newRelayer;
    }
    
    function consumeFromQueue() public onlyRelayer returns (Message memory){
        require(queue.length > 0, "QUEUE_EMPTY");
        
        Message memory m;
        m = queue[0];
        
        delete queue[0];
        
        // Pay fee to relayer for consuming and executing message
        payable(TRUSTED_RELAYER).transfer(payment);

        return m;
    }

    // Core implementation
    // Make payable and add payment for 
    function send(address recipient, bytes calldata data) public payable {
        
        require(msg.value >= minFee, "NEED_MORE_ETHER_FOR_TXN");

        // TODO(@ckartik): Figure out pricing mechanism here.
        queue.push(Message({
            sender: msg.sender, 
            reciever: recipient, 
            callData: data
        }));

        // TODO: Emit message here
    }

    // recieve executes 
    function receive(Message calldata message) public onlyRelayer {
        // We want to ensure relayer does not execute arbitrary computation on this contract.
        require(message.reciever != address(this), "FORBIDDEN_ACTION");

        (bool success, bytes memory data) = message.reciever.call(message.callData);
        require(success, "EXTERNAL_CALL_FAILED");
    }
}