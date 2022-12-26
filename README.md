# AMB - Arbitrary Message Bridge for Cross-Chain communication

## AMB
- We developed a simple AMB that allows you to send arbitrary encoded commands cross-chain using.
- For example you can do the following to exectute a function on a contract at as targetAddress:
```solidity
        AMB.send(targetAddress, abi.encodeWithSignature("publicFunctionAtTargetAddress()", "arg1", arg2"...));

```

## Simple Example of an Incrementable Counter
- To showcase use of the simple AMB, we create a counter contract that allows you send message to increment a smart-contract on a corresponding chain.