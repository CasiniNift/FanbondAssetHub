import { expect } from "chai";
import { ethers } from "hardhat";
import { FanbondWithReferral } from "../typechain-types";

describe("FanbondWithReferral", function () {
  let fanbondWithReferral: FanbondWithReferral;

  beforeEach(async function () {
    const FanbondWithReferralFactory = await ethers.getContractFactory("FanbondWithReferral");
    fanbondWithReferral = await FanbondWithReferralFactory.deploy("FanBondRef", "FBDR", 250) as FanbondWithReferral;
    await fanbondWithReferral.waitForDeployment();
  });

  it("Should deploy with correct name, symbol, and referral fee", async function () {
    expect(await fanbondWithReferral.name()).to.equal("FanBondRef");
    expect(await fanbondWithReferral.symbol()).to.equal("FBDR");
    expect(await fanbondWithReferral.referralFeePercent()).to.equal(250);
  });

  // Add more tests for FanbondWithReferral functionality
});
