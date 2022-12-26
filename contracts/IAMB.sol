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

contract AMB {
    address TRUSTED_RELAYER;
    address OWNER;
    uint minFee;
    uint payment;
    Message[] queue; 

    constructor() { 
       TRUSTED_RELAYER = msg.sender;
       OWNER = msg.sender;
       minFee = 0.0002 ether;
       payment = 0.0001 ether;
    }

    // Adding these for dynamic consumption by a Relayer/FE Dapp
    event MessageConsumed(address sender, address reciever, bytes callData);
    event NotifyRelayer(address sender, address reciever, bytes callData);

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
    
    // getQueueHead retrieves the top most queued message in the AMB
    function getQueueHead() public view onlyRelayer returns (Message memory) {
        require(queue.length > 0, "QUEUE_EMPTY");
        return queue[0];
    }

    // consumeFromQueue removes the message and pays out the relayer
    // assumes the trusted relayer has executed the message on a corresponding chain
    function consumeFromQueue() public onlyRelayer {
        require(queue.length > 0, "QUEUE_EMPTY");

        Message memory m;
        m = queue[0];

        delete queue[0];
        payable(TRUSTED_RELAYER).transfer(payment);

        emit MessageConsumed(m.sender, m.reciever, m.callData);
    }

    // send is the interface for a user to send a message cross chain using this amb
    // it requires the address of the recipient and the data encoding the rquired call 
    // to the external contract.
    function send(address recipient, bytes calldata data) public payable {        
        require(msg.value >= minFee, "NEED_MORE_ETHER_FOR_TXN");

        queue.push(Message({
            sender: msg.sender, 
            reciever: recipient, 
            callData: data
        }));

        emit NotifyRelayer(msg.sender, recipient, data);
    }

    // recieve executes [message.callData] on the [message.reciever] contract.
    // the caller must be a trusted relayer.
    function receive(Message calldata message) public onlyRelayer {
        // We want to ensure relayer does not execute arbitrary computation on this contract.
        require(message.reciever != address(this), "FORBIDDEN_ACTION");

        (bool success, bytes memory data) = message.reciever.call(message.callData);
        require(success, "EXTERNAL_CALL_FAILED");
    }
}