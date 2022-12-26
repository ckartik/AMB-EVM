# AMBCC - Arbitrary Message Bridge for Cross-Chain communication

## E2E testing on multiple contracts on Goreli

### 1. Set up a .env file with:
```bash
API_KEY=<Infura-API-Key>
PRIV_KEY1=<Relayer-Private-Key>
PRIV_KEY2=<Message-Sender-DAPP-Private-Key>
```
### 2. Run the following commands:
```bash
$ npm install
$ npx hardhat test
```

## AMB
- We developed a simple AMB that allows you to send arbitrary encoded commands cross-chain.
- For example you can do the following to exectute a function on a contract at as targetAddress:
```solidity
        AMB.send(targetAddress, abi.encodeWithSignature("targetFunc()", "arg1", arg2"...));

```

## Simple Example of an Incrementable Counter
- To showcase use of the simple AMB, we create a counter contract that allows you send message to increment a smart-contract on a corresponding chain.

## Sequence Diagram of smart-contract/service interactions
```mermaid
sequenceDiagram
DAPP ->> DAPP: listen()
owner ->> Counter1: deploy()
owner ->> AMBChain1: deploy()
owner ->> Counter2: deploy()
owner ->> Counter1: setReceivingCounter(Counter2Address)
DAPP ->> Counter1: send() + funds
Counter1 ->> AMBChain1: send(Counter2Address, calldata("increment()"))
AMBChain1 ->> AMBChain1: messageQueue.push(recipient+calldata)
Relayer ->> AMBChain1: ReadQueueHead()
Relayer ->> AMBChain2: recieve(Counter2Address, calldata("increment()"))
AMBChain2 ->> Counter2: call(message.callData)
Relayer ->> AMBChain1: consumeFromQueue()
```
