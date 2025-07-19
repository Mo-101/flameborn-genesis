// SPDX-License-Identifier: MIT
        
pragma solidity ^0.8.24;

// This import is automatically injected by Remix
import { Assert } from "remix_tests.sol";
import { TestsAccounts } from "remix_accounts.sol";
import "@openzeppelin/contracts/token/ERC20/FlameBornToken.sol";
import "@openzeppelin/contracts/token/ERC20/FlameBornTokenSale.sol";
import {FlameBornToken as TokenContract}from "@openzeppelin/contracts/token/ERC20/FlameBornToken.sol";
import {ERC20 as Contract}from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // Instantiate contract
        token = new FlameBornToken(1000); // Initial supply of 1000 tokens

        // Define roles for testing
        daoRole = keccak256("DAO_ROLE");
        validatorRole = keccak256("VALIDATOR_ROLE");
        youthRole = keccak256("YOUTH_ROLE");
        elderRole = keccak256("ELDER_ROLE");
        tribalCouncilRole = keccak256("TRIBAL_COUNCIL_ROLE");
    }

    function beforeEach() public {
        // Reset state before each test if necessary
        // For example, you might want to re-deploy the contract or reset balances
    }

    // Test suite for role management
    function testRoleManagement() public {
        address admin = TestsAccounts.getAccount(0);
        address newValidator = TestsAccounts.getAccount(1);

        // Check if the deployer has the default admin role
        Assert.isTrue(token.hasRole(token.DEFAULT_ADMIN_ROLE(), admin), "Deployer should have admin role");

        // Grant the validator role to a new address
        token.grantRole(validatorRole, newValidator);
        Assert.isTrue(token.hasRole(validatorRole, newValidator), "Should grant validator role");

        // Revoke the validator role
        token.revokeRole(validatorRole, newValidator);
        Assert.isFalse(token.hasRole(validatorRole, newValidator), "Should revoke validator role");
    }

    // Test suite for identity registration and verification
    function testIdentityVerification() public {
        address user = TestsAccounts.getAccount(2);
        address tribalCouncil = TestsAccounts.getAccount(3);
        string memory idHash = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";

        // Register identity
        token.registerIdentity(keccak256(abi.encodePacked("TestID")));
        Assert.notEqual(bytes(token.getAfricanID(user)).length, 0, "Identity should be registered");

        // Verify by tribal council
        token.grantRole(tribalCouncilRole, tribalCouncil);
        vm.prank(tribalCouncil); // Set the sender for the next call
        token.verifyByTribalCouncil(user, idHash);
        Assert.isTrue(token.isAfricanOrigin(user), "User should be verified");
        Assert.equal(token.getVerificationMethod(user), FlameBornToken.VerificationType.TRIBAL_COUNCIL, "Verification method should be Tribal Council");
    }

    // Test suite for token minting after validation
    function testMintAfterValidation() public {
        address validator = TestsAccounts.getAccount(4);
        address recipient = TestsAccounts.getAccount(5);

        // Setup: Register and verify identity for recipient
        string memory idHash = "0xfedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321";
        token.registerIdentity(keccak256(abi.encodePacked("RecipientID")));
        token.grantRole(tribalCouncilRole, validator);
        vm.prank(validator);
        token.verifyByTribalCouncil(recipient, idHash);

        // Mint tokens after validation
        uint256 mintAmount = 100;
        token.grantRole(validatorRole, validator);
        vm.prank(validator);
        token.mintAfterValidation(recipient, mintAmount, "ValidationProof");
        Assert.equal(token.balanceOf(recipient), mintAmount, "Recipient should receive tokens");
    }

    // Test suite for rewarding youth actions
    function testRewardYouthAction() public {
        address youth = TestsAccounts.getAccount(6);
        address youthLeader = TestsAccounts.getAccount(7);

        // Setup: Register and verify identity for youth
        string memory idHash = "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890";
        token.registerIdentity(keccak256(abi.encodePacked("YouthID")));
        token.grantRole(tribalCouncilRole, youthLeader);
        vm.prank(youthLeader);
        token.verifyByTribalCouncil(youth, idHash);

        // Reward youth action
        uint256 rewardAmount = 50;
        token.grantRole(youthRole, youthLeader);
        vm.prank(youthLeader);
        token.rewardYouthAction(youth, rewardAmount, "YouthAction");
        Assert.equal(token.balanceOf(youth), rewardAmount, "Youth should receive reward tokens");
    }

    // Test suite for token burning
    function testTokenBurning() public {
        address burner = TestsAccounts.getAccount(8);

        // Setup: Mint tokens to an account
        uint256 initialSupply = 1000; // Assuming initialSupply is 1000
        token.transfer(burner, 100); // Transfer some tokens to burner

        // Burn tokens
        uint256 burnAmount = 30;
        token.grantRole(daoRole, TestsAccounts.getAccount(0)); // Grant DAO role to the deployer for burning
        vm.prank(TestsAccounts.getAccount(0));
        token.burn(burner, burnAmount);
        Assert.equal(token.balanceOf(burner), 70, "Tokens should be burned from account");
    }

    // Test suite for controlled minting
    function testControlledMinting() public {
        address minter = TestsAccounts.getAccount(9);
        uint256 mintAmount = 500;

        // Controlled mint
        token.controlledMint(minter, mintAmount);
        Assert.equal(token.balanceOf(minter), mintAmount, "Should mint tokens via controlledMint");
    }

    // Test suite for issuing soulprints
    function testIssueSoulprint() public {
        address user = TestsAccounts.getAccount(2);
        address soulprintIssuer = TestsAccounts.getAccount(0);

        // Setup: Verify identity for recipient
        string memory idHash = "0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";
        token.registerIdentity(keccak256(abi.encodePacked("TestUser")));
        token.grantRole(tribalCouncilRole, soulprintIssuer);
        vm.prank(soulprintIssuer);
        token.verifyByTribalCouncil(user, idHash);

        // Issue soulprint
        string memory soulHash = "SoulprintHash";
        uint256 weight = 1;
        token.grantRole(daoRole, soulprintIssuer);
        vm.prank(soulprintIssuer);
        token.issueSoulprint(user, soulHash, weight);
        // No direct state change to assert for soulprints, verify event emission if possible
        // You might need to check logs or use a specific event testing approach
    }

    // Test suite for token transfers (soulbound checks)
    function testTokenTransfers() public {
        address sender = TestsAccounts.getAccount(1);
        address recipient = TestsAccounts.getAccount(2);
        address tribalCouncil = TestsAccounts.getAccount(3);

        // Setup: Mint tokens and verify recipient
        token.controlledMint(sender, 100);
        string memory idHash = "0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";
        token.registerIdentity(keccak256(abi.encodePacked("RecipientID")));
        token.grantRole(tribalCouncilRole, tribalCouncil);
        vm.prank(tribalCouncil);
        token.verifyByTribalCouncil(recipient, idHash);

        // Test: Attempt to transfer tokens - should fail because sender is not verified
        vm.expectRevert(bytes("TransferNotAllowed()"));
        token.transfer(recipient, 10);

        // Test: Attempt to transfer tokens - should succeed because sender is verified
        string memory senderIdHash = "0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdee";
        token.registerIdentity(keccak256(abi.encodePacked("SenderID")));
        vm.prank(tribalCouncil);
        token.verifyByTribalCouncil(sender, senderIdHash);
        vm.prank(sender);
        token.transfer(recipient, 10);
        Assert.equal(token.balanceOf(recipient), 10, "Token transfer should succeed");
    }

    // State variables to hold the contract and roles
    FlameBornToken token;
    bytes32 daoRole;
    bytes32 validatorRole;
    bytes32 youthRole;
    bytes32 elderRole;
    bytes32 tribalCouncilRole;

}