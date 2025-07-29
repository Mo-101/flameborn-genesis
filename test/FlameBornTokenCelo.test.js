const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FlameBornToken", function () {
  let token;
  let owner, validator, user1, user2, tribalCouncil, youthLeader;
  
  // Role hashes
  const DAO_ROLE = ethers.keccak256(ethers.toUtf8Bytes("DAO_ROLE"));
  const VALIDATOR_ROLE = ethers.keccak256(ethers.toUtf8Bytes("VALIDATOR_ROLE"));
  const YOUTH_ROLE = ethers.keccak256(ethers.toUtf8Bytes("YOUTH_ROLE"));
  const ELDER_ROLE = ethers.keccak256(ethers.toUtf8Bytes("ELDER_ROLE"));
  const TRIBAL_COUNCIL_ROLE = ethers.keccak256(ethers.toUtf8Bytes("TRIBAL_COUNCIL_ROLE"));
  const DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000";

  before(async function () {
    // Get signers
    [owner, validator, user1, user2, tribalCouncil, youthLeader] = await ethers.getSigners();
    
    // Deploy the token contract
    const Token = await ethers.getContractFactory("FlameBornToken");
    token = await Token.deploy(ethers.parseEther("1000000")); // Initial supply of 1000 tokens
    
    // Grant roles for testing
    await token.grantRole(VALIDATOR_ROLE, validator.address);
    await token.grantRole(YOUTH_ROLE, youthLeader.address);
    await token.grantRole(TRIBAL_COUNCIL_ROLE, tribalCouncil.address);
  });

  describe("Role Management", function () {
    it("should grant admin role to deployer", async function () {
      expect(await token.hasRole(DEFAULT_ADMIN_ROLE, owner.address)).to.be.true;
    });

    it("should allow admin to grant and revoke roles", async function () {
      // Grant role
      await token.grantRole(VALIDATOR_ROLE, user1.address);
      expect(await token.hasRole(VALIDATOR_ROLE, user1.address)).to.be.true;
      
      // Revoke role
      await token.revokeRole(VALIDATOR_ROLE, user1.address);
      expect(await token.hasRole(VALIDATOR_ROLE, user1.address)).to.be.false;
    });
  });

  describe("Identity Verification", function () {
    const idHash = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";
    
    it("should allow users to register identity", async function () {
      await token.connect(user1).registerIdentity(ethers.keccak256(ethers.toUtf8Bytes("TestID")));
      const user1Id = await token.getAfricanID(user1.address);
      expect(user1Id).to.not.equal(ethers.ZeroHash);
    });

    it("should allow tribal council to verify identity", async function () {
      await token.connect(tribalCouncil).verifyByTribalCouncil(user1.address, idHash);
      expect(await token.isAfricanOrigin(user1.address)).to.be.true;
    });
  });

  describe("Token Operations", function () {
    it("should allow burning tokens", async function () {
      const burnAmount = ethers.parseEther("10");
      // Burn from user1 (after minting)
      await token.connect(validator).mintAfterValidation(user1.address, burnAmount, "proofBurn");
      const balanceBefore = await token.balanceOf(user1.address);
      await token.connect(user1).burn(burnAmount);
      const balanceAfter = await token.balanceOf(user1.address);
      expect(balanceAfter).to.equal(balanceBefore - burnAmount);
    });

    it("should emit events on mint and burn", async function () {
      const mintAmount = ethers.parseEther("5");
      await expect(token.connect(validator).mintAfterValidation(user1.address, mintAmount, "proofEvent"))
        .to.emit(token, "MintedAfterValidation")
        .withArgs(user1.address, mintAmount, "proofEvent");
      await expect(token.connect(user1).burn(mintAmount))
        .to.emit(token, "FLBBurned");
    });

    const mintAmount = ethers.parseEther("100");
    
    before(async function () {
      // Setup: Register and verify user1
      await token.connect(user1).registerIdentity(ethers.keccak256(ethers.toUtf8Bytes("User1ID")));
      await token.connect(tribalCouncil).verifyByTribalCouncil(user1.address, "0x" + "1".repeat(64));
    });

    it("should allow minting after validation", async function () {
      await token.connect(validator).mintAfterValidation(user1.address, mintAmount, "proof123");
      expect(await token.balanceOf(user1.address)).to.equal(mintAmount);
    });

    it("should allow token transfers between verified users", async function () {
      // Verify user2
      await token.connect(user2).registerIdentity(ethers.keccak256(ethers.toUtf8Bytes("User2ID")));
      await token.connect(tribalCouncil).verifyByTribalCouncil(user2.address, "0x" + "2".repeat(64));
      
      // Transfer tokens
      const transferAmount = ethers.parseEther("10");
      await token.connect(user1).transfer(user2.address, transferAmount);
      expect(await token.balanceOf(user2.address)).to.equal(transferAmount);
    });
  });

  describe("Access Control", function () {
    it("should prevent unauthorized minting", async function () {
      await expect(
        token.connect(user1).mintAfterValidation(user2.address, 100, "invalid")
      ).to.be.revertedWith("AccessControl: account");
    });

    it("should prevent transfers from unverified addresses", async function () {
      const unverifiedUser = user2; // user2 is not verified in this context
      await expect(
        token.connect(unverifiedUser).transfer(user1.address, 10)
      ).to.be.revertedWith("TransferNotAllowed()");
    });
  });
});
