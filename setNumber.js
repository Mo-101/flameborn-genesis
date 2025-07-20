const { ethers } = require("ethers");

async function main() {
    // Connect to the provider
    const provider = new ethers.providers.Web3Provider(web3.currentProvider);

    // Get the signer
    const signer = provider.getSigner();

    // Get the contract factory
    const MyContract = await ethers.getContractFactory("MyContract", signer);

    // Deploy the contract
    const myContract = await MyContract.deploy();
    await myContract.deployed();

    // Set a new number
    await myContract.setNumber(42);

    console.log("New number set to:", await myContract.myNumber());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });