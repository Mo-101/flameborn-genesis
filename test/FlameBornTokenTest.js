const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('FlameBornTokenV3', function () {
  let FlameBornToken;
  let flbToken;
  let owner;
  let addr1;
  let addr2;
  let initialSupply = 1000000;

  beforeEach(async function () {
    FlameBornToken = await ethers.getContractFactory('FlameBornTokenV3');
    [owner, addr1, addr2] = await ethers.getSigners();
    flbToken = await FlameBornToken.deploy(initialSupply);
    // Removed flbToken.deployed() as it's not needed with ethers.js
  });

  describe('Deployment', function () {
    it('Should set the right owner', async function () {
      expect(await flbToken.hasRole(await flbToken.DEFAULT_ADMIN_ROLE(), owner.address)).to.equal(true);
    });

    it('Should assign the initial supply to the creator', async function () {
      const ownerBalance = await flbToken.balanceOf(owner.address);
      expect(ownerBalance).to.equal(ethers.parseEther(initialSupply.toString()));
    });
  });

  describe('Soulbound Logic', function () {
    it('Should mark tokens as soulbound on minting', async function () {
      // Owner is automatically soulbound during deployment
      expect(await flbToken.isAfricanOrigin(owner.address)).to.equal(true);
    });

    it('Should prevent transfers between users', async function () {
      await expect(
        flbToken.transfer(addr1.address, ethers.parseEther('100'))
      ).to.be.revertedWithCustomError(flbToken, 'TransferNotAllowed');
    });
  });

  describe('Minting', function () {
    it('Should allow minting by validator role', async function () {
      // Grant validator role to addr1
      const validatorRole = await flbToken.VALIDATOR_ROLE();
      await flbToken.grantRole(validatorRole, addr1.address);

      // Verify African origin for addr2 (normally done via verifyByTribalCouncil or other methods)
      const tribalCouncilRole = await flbToken.TRIBAL_COUNCIL_ROLE();
      await flbToken.grantRole(tribalCouncilRole, owner.address);
      await flbToken.verifyByTribalCouncil(addr2.address, 'TEST_ID_HASH');

      // Mint tokens as validator
      await flbToken.connect(addr1).mintAfterValidation(addr2.address, ethers.parseEther('500'), 'ValidationProof');
      expect(await flbToken.balanceOf(addr2.address)).to.equal(ethers.parseEther('500'));
    });

    it('Should fail minting to unverified address', async function () {
      const validatorRole = await flbToken.VALIDATOR_ROLE();
      await flbToken.grantRole(validatorRole, addr1.address);

      await expect(
        flbToken.connect(addr1).mintAfterValidation(addr2.address, ethers.parseEther('500'), 'ValidationProof')
      ).to.be.revertedWithCustomError(flbToken, 'NotRegistered');
    });
  });

  describe('Burning', function () {
    it('Should allow burning by DAO role', async function () {
      const daoRole = await flbToken.DAO_ROLE();
      await flbToken.grantRole(daoRole, addr1.address);

      const initialBalance = await flbToken.balanceOf(owner.address);
      const burnAmount = ethers.parseEther('100');
      // Explicitly call the burn(address, uint256) function to disambiguate from burn(uint256)
      await flbToken.connect(addr1)['burn(address,uint256)'](owner.address, burnAmount);
      const finalBalance = await flbToken.balanceOf(owner.address);
      const expectedBalance = (BigInt(initialBalance.toString()) - BigInt(burnAmount.toString())).toString();
      expect(finalBalance.toString()).to.equal(expectedBalance.toString());
    });
  });

  describe('Identity Registration', function () {
    it('Should allow identity registration', async function () {
      await flbToken.connect(addr1).registerIdentity(ethers.keccak256(ethers.toUtf8Bytes('ID_HASH_1')));
      expect(await flbToken.getAfricanID(addr1.address)).to.not.equal('');
    });

    it('Should prevent re-registration', async function () {
      await flbToken.connect(addr1).registerIdentity(ethers.keccak256(ethers.toUtf8Bytes('ID_HASH_1')));
      await expect(
        flbToken.connect(addr1).registerIdentity(ethers.keccak256(ethers.toUtf8Bytes('ID_HASH_2')))
      ).to.be.revertedWithCustomError(flbToken, 'AlreadyRegistered');
    });
  });
});
