const ethers = require('ethers');

function generateRandomAddresses(count) {
  const addresses = [];
  for (let i = 0; i < count; i++) {
    const wallet = ethers.Wallet.createRandom();
    addresses.push(wallet.address);
  }
  return addresses;
}

const randomAddresses = generateRandomAddresses(3);
console.log("Random Test Addresses:", randomAddresses);
