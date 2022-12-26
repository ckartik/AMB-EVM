// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

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


 // TODO(@ckartik): Make amb payable with a min fee.
contract AMB {
    address TRUSTED_RELAYER;
    Message[] queue; 

    constructor() { 
       TRUSTED_RELAYER = msg.sender;
    }

    function getQueue() public view returns (Message[] memory) {
        return queue;
    }
    
    // Core implementation
    function send(address recipient, bytes calldata data) public {
        queue.push(Message({
            sender: msg.sender, 
            reciever: recipient, 
            callData: data
        }));
    }

    function receive(Message calldata message) public {
        require(msg.sender == TRUSTED_RELAYER, "UNTRUSTED_SENDER");
        // TOOD: Figure out how to make contract to contract call.
        (bool success, bytes memory data) = message.reciever.call(message.callData);
    }
}