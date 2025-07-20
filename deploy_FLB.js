(async () => {
    try {
      // Load contract metadata (adjust path as needed)
      const metadata = JSON.parse(await remix.call('fileManager', 'getFile', 'browser/artifacts/FlameBornTokenV3BSC.json'));
      const [signer] = await ethers.getSigners();
  
      // Deploy contract
      const factory = new ethers.ContractFactory(metadata.abi, metadata.data.bytecode.object, signer);
      const contract = await factory.deploy(1000000); // Pass constructor args if needed
      await contract.deployed();
      console.log('Contract deployed at:', contract.address);
    } catch (e) {
      console.log('Error:', e.message);
    }
  })();