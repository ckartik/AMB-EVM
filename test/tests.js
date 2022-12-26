const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Counter", function () {
  // Deploys a new AMB and returns an abi wrapped instance to it.
  async function deployMessageBridge() {
    const AMB = await ethers.getContractFactory("AMB");
    const amb = await AMB.deploy();
    console.log(`AMB contract deployed to ${amb.address}`)

    return amb
  }

  // deployCounter deploys a counter contract configured to use an AMB deployed to [bridgeAddress] and returns an abi wrapped instance.
  async function deployCounter(bridgeAddress) {
    const Counter = await ethers.getContractFactory("Counter");
    const counter = await Counter.deploy(bridgeAddress);
    console.log(`Counter contract deployed to ${counter.address}`)

    return counter
  }

  describe("Deployment and Integeration Testing", function () {
    
    it("Should send proxy message through amb on the same chain and contract", async function () {
      
      const amb = await deployMessageBridge();
      const counter =  await deployCounter(amb.address);
      
      // set the recieving counter contract to itself for easy test
      const txn1 = await counter.setReceivingCounter(counter.address);
      await txn1.wait()
      // Send Transaction to queue for external contract
      const txn2 = await counter.send({value: ethers.utils.parseUnits("0.0002", "ether")});
      await txn2.wait()

      // TODO(@ckartik): Make amb interface cleaner and also start using events
      const data = await amb.getQueueHead();

      // We ensure that the relayer will pick up from and increment to the same contract
      expect(data.sender).to.equal(data.reciever)

      // Increment directly
      expect(await counter.getCount()).to.equal(0)
      const txn3 = await counter.increment()
      await txn3.wait()
      expect(await counter.getCount()).to.equal(1)

      // Increment through amb proxy
      const txn4 = await amb.receive(data)
      await txn4.wait()
      expect(await counter.getCount()).to.equal(2)
    })

    it("Should send proxy message through amb on the same chain and but different contract", async function () {
      const amb = await deployMessageBridge();
      const counter =  await deployCounter(amb.address);

      const amb2 = await deployMessageBridge();
      const counter2 =  await deployCounter(amb2.address);

      const txn2 = await counter.setReceivingCounter(counter2.address);
      await txn2.wait()

      // Send Transaction to queue for external contract
      const txn3  = await counter.send({value: ethers.utils.parseUnits("0.0002", "ether")});
      await txn3.wait()

      const data = await amb.getQueueHead();

      expect(await counter2.getCount()).to.equal(0)

      // Increment through amb proxy
      const txn4 = await amb2.receive(data)
      await txn4.wait()
      expect(await counter2.getCount()).to.equal(1)
    });

    it("Should send proxy message through amb on the same chain and but different contract and get paid", async function () {
      const [relayer, otherAccount] = await ethers.getSigners()

      const amb = await deployMessageBridge();
      const counter =  await deployCounter(amb.address);

      const amb2 = await deployMessageBridge();
      const counter2 =  await deployCounter(amb2.address);


      const txn1 = await counter.setReceivingCounter(counter2.address);
      await txn1.wait()
     
      // Send Transaction to queue for external contract
      const txn2 = await counter.connect(otherAccount).send({value: ethers.utils.parseUnits("0.0002", "ether")});
      const reciept = await txn2.wait()

      


      const data = await amb.getQueueHead();
    
      expect(await counter2.getCount()).to.equal(0)

      // Increment through amb proxy
      const txn3 = await amb2.receive(data)
      await txn3.wait()

      expect(await counter2.getCount()).to.equal(1)

      const balanceT0 = await relayer.getBalance();

      const txn4 = await amb.consumeFromQueue();
      await txn4.wait()

      const balanceT1 = await relayer.getBalance();
      expect(balanceT1).to.greaterThan(balanceT0);

      console.log(`${relayer.address} earned ${balanceT1 - balanceT0} wei`)
    });
  });
});