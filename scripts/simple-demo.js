const { ethers } = require("hardhat");

async function main() {
  console.log("NFT Marketplace Simple Demo");
  console.log("===========================");

  const [deployer, seller, buyer] = await ethers.getSigners();
  
  const addresses = require("../deployed-addresses.json");
  console.log("Using contracts from latest deployment");
  
  const NFT = await ethers.getContractFactory("COMP5521NFT");
  const Marketplace = await ethers.getContractFactory("Marketplace");
  
  const nft = await NFT.attach(addresses.nft);
  const marketplace = await Marketplace.attach(addresses.marketplace);

  console.log("Accounts:");
  console.log("Deployer:", deployer.address);
  console.log("Seller:  ", seller.address);
  console.log("Buyer:   ", buyer.address);

  console.log("\n1. Testing marketplace functions...");
  
  console.log("a) Listing NFT 1 for sale...");
  await nft.connect(seller).approve(marketplace.target, 1);
  const price = ethers.parseEther("1.0");
  await marketplace.connect(seller).listNFT(nft.target, 1, price);
  console.log("   Listed NFT 1 for 1.0 C5D");

  console.log("b) Cancelling listing...");
  await marketplace.connect(seller).cancelListing(nft.target, 1);
  console.log("   Cancelled listing for NFT 1");

  console.log("\n2. Testing complete - basic functions working");
  console.log("   - NFT approval");
  console.log("   - Listing creation"); 
  console.log("   - Listing cancellation");

  console.log("\n===========================");
  console.log("DEMO COMPLETED SUCCESSFULLY");
  console.log("Marketplace core functions verified");
  console.log("===========================");
}

main().catch(console.error);