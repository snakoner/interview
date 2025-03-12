import {HardhatEthersSigner} from "@nomicfoundation/hardhat-ethers/src/signers";
import {ethers} from "hardhat";
import {expect} from "chai";
import {Logic, CloneFactory} from "../typechain-types";
import "@nomicfoundation/hardhat-chai-matchers";


let logic: Logic;
let cloneFactory: CloneFactory;
let owner: HardhatEthersSigner;

const cloneAbi = [
  "function setValue(uint256 newValue) external",
];

const init = async() => {
    owner = (await ethers.getSigners())[0];
    
    // logic
    const logicFactory = await ethers.getContractFactory("Logic");
    logic = await logicFactory.deploy();
    await logic.waitForDeployment();
    

    // clone factory
    const cloneFactoryFactory = await ethers.getContractFactory("CloneFactory");
    cloneFactory = await cloneFactoryFactory.deploy(await logic.getAddress());
    await cloneFactory.waitForDeployment();
}

describe("Minimal proxy test", function() {
    beforeEach(async function () {
        await init();
    });

    it ("Should be possible to create new clone", async function() {
      const clone0 = await cloneFactory.createClone();
      const receipt0 = await clone0.wait();

      let txBlockNumber = receipt0?.blockNumber;
      let events = await cloneFactory.queryFilter(cloneFactory.filters.CloneCreated(), txBlockNumber, "latest");
      let cloneAddress = (events[0].args[0]);

      console.log(cloneAddress);

      const logicCloneContract0 = new ethers.Contract(cloneAddress, cloneAbi, owner);
      await logicCloneContract0.setValue(0x1234);
      let zeroSlotValue = await ethers.provider.getStorage(await logicCloneContract0.getAddress(), 0);

      expect(ethers.toBigInt(zeroSlotValue)).to.be.eq(ethers.toBigInt(0x1234));

      // second clone
      const clone1 = await cloneFactory.createClone();
      const receipt1 = await clone1.wait();

      txBlockNumber = receipt1?.blockNumber;
      events = await cloneFactory.queryFilter(cloneFactory.filters.CloneCreated(), txBlockNumber, "latest");
      cloneAddress = (events[0].args[0]);

      console.log(cloneAddress);

      const logicCloneContract1 = new ethers.Contract(cloneAddress, cloneAbi, owner);
      await logicCloneContract1.setValue(0x2345);
      let zeroSlotValue0 = await ethers.provider.getStorage(await logicCloneContract0.getAddress(), 0);
      let zeroSlotValue1 = await ethers.provider.getStorage(await logicCloneContract1.getAddress(), 0);

      expect(ethers.toBigInt(zeroSlotValue0)).to.be.eq(ethers.toBigInt(0x1234));
      expect(ethers.toBigInt(zeroSlotValue1)).to.be.eq(ethers.toBigInt(0x2345));

      expect(await cloneFactory.getProxiesNumber()).to.be.eq(2);
      expect(await cloneFactory.proxies(0)).to.be.eq(await logicCloneContract0.getAddress());
      expect(await cloneFactory.proxies(1)).to.be.eq(await logicCloneContract1.getAddress());
    });
})