const { ethers } = require("ethers");

async function main() {
    // Connect to the provider
    const provider = new ethers.providers.Web3Provider(web3.currentProvider);

    // Get the signer
    const signer = provider.getSigner();

    // Get the contract factory
    const FlameBornTokenFactory = await ethers.getContractFactory("FlameBornToken", signer);

    // Deploy the contract
    const FlameBornToken = await FlameBornTokenFactory.deploy("FlameBornToken", "FLB");
    await FlameBornToken.deployed();

    console.log("Contract deployed to:", FlameBornToken.address);

    // Set a new number
    await FlameBornToken.setNumber(42);

    console.log("New number set to:", await FlameBornToken.myNumber());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });