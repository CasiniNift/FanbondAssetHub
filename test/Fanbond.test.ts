import { expect } from "chai";
import { ethers } from "hardhat";
import { Fanbond } from "../typechain-types";

describe("Fanbond", function () {
  let fanbond: Fanbond;

  beforeEach(async function () {
    const FanbondFactory = await ethers.getContractFactory("Fanbond");
    fanbond = await FanbondFactory.deploy("FanBond", "FBD") as Fanbond;
    await fanbond.waitForDeployment();
  });

  it("Should deploy with correct name and symbol", async function () {
    expect(await fanbond.name()).to.equal("FanBond");
    expect(await fanbond.symbol()).to.equal("FBD");
  });

  // Add more tests for Fanbond functionality
});
