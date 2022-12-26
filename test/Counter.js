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

  describe("Unit Testing", function () {
  });

  describe("Deployment and Integeration Testing", function () {
    it("Should send proxy message through amb on the same chain and contract", async function () {
      const amb = await deployMessageBridge();
      const counter =  await deployCounter(amb.address);

      // set the recieving counter contract to itself for easy test
      await counter.setReceivingCounter(counter.address);

      // Send Transaction to queue for external contract
      await counter.send({value: ethers.utils.parseUnits("25", "gwei")});

      // TODO(@ckartik): Make amb interface cleaner and also start using events
      const data = (await amb.getQueue())[0]

      // We ensure that the relayer will pick up from and increment to the same contract
      expect(data.sender).to.equal(data.reciever)

      // Increment directly
      expect(await counter.getCount()).to.equal(0)
      await counter.increment()
      expect(await counter.getCount()).to.equal(1)

      // Increment through amb proxy
      await amb.receive(data)
      expect(await counter.getCount()).to.equal(2)
    })

    it("Should send proxy message through amb on the same chain and but different contract", async function () {
      const amb = await deployMessageBridge();
      const counter =  await deployCounter(amb.address);

      const amb2 = await deployMessageBridge();
      const counter2 =  await deployCounter(amb2.address);
      // set the recieving counter contract to itself for easy test
      await counter.setReceivingCounter(counter2.address);

      // Send Transaction to queue for external contract
      await counter.send({value: ethers.utils.parseUnits("25", "gwei")});

      // TODO(@ckartik): Make amb interface cleaner and also start using events
      const data = (await amb.getQueue())[0]
      // Increment directly
      expect(await counter2.getCount()).to.equal(0)

      // Increment through amb proxy
      await amb2.receive(data)
      expect(await counter2.getCount()).to.equal(1)
    });
  });
});

//     it("Should receive and store the funds to lock", async function () {
//       const { lock, lockedAmount } = await loadFixture(
//         deployOneYearLockFixture
//       );

//       expect(await ethers.provider.getBalance(lock.address)).to.equal(
//         lockedAmount
//       );
//     });

//     it("Should fail if the unlockTime is not in the future", async function () {
//       // We don't use the fixture here because we want a different deployment
//       const latestTime = await time.latest();
//       const Lock = await ethers.getContractFactory("Lock");
//       await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
//         "Unlock time should be in the future"
//       );
//     });
//   });

//   describe("Withdrawals", function () {
//     describe("Validations", function () {
//       it("Should revert with the right error if called too soon", async function () {
//         const { lock } = await loadFixture(deployOneYearLockFixture);

//         await expect(lock.withdraw()).to.be.revertedWith(
//           "You can't withdraw yet"
//         );
//       });

//       it("Should revert with the right error if called from another account", async function () {
//         const { lock, unlockTime, otherAccount } = await loadFixture(
//           deployOneYearLockFixture
//         );

//         // We can increase the time in Hardhat Network
//         await time.increaseTo(unlockTime);

//         // We use lock.connect() to send a transaction from another account
//         await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
//           "You aren't the owner"
//         );
//       });

//       it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
//         const { lock, unlockTime } = await loadFixture(
//           deployOneYearLockFixture
//         );

//         // Transactions are sent using the first signer by default
//         await time.increaseTo(unlockTime);

//         await expect(lock.withdraw()).not.to.be.reverted;
//       });
//     });

//     describe("Events", function () {
//       it("Should emit an event on withdrawals", async function () {
//         const { lock, unlockTime, lockedAmount } = await loadFixture(
//           deployOneYearLockFixture
//         );

//         await time.increaseTo(unlockTime);

//         await expect(lock.withdraw())
//           .to.emit(lock, "Withdrawal")
//           .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
//       });
//     });

//     describe("Transfers", function () {
//       it("Should transfer the funds to the owner", async function () {
//         const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
//           deployOneYearLockFixture
//         );

//         await time.increaseTo(unlockTime);

//         await expect(lock.withdraw()).to.changeEtherBalances(
//           [owner, lock],
//           [lockedAmount, -lockedAmount]
//         );
//       });
//     });
//   });
// });
