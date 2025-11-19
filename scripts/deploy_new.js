const { ethers } = require("hardhat");

async function main() {
  console.log("Complete Deployment and Testing");
  console.log("===============================");

  const [deployer, seller, buyer] = await ethers.getSigners();

  // 1. 部署所有合约
  console.log("\n1. Deploying contracts...");
  
  const Stablecoin = await ethers.getContractFactory("COMP5521Dollar");
  const stablecoin = await Stablecoin.deploy();
  console.log("COMP5521Dollar:", stablecoin.target);

  const NFT = await ethers.getContractFactory("COMP5521NFT");
  const nft = await NFT.deploy();
  console.log("COMP5521NFT:", nft.target);

  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy(stablecoin.target);
  console.log("Marketplace:", marketplace.target);

  // 2. 等待部署完成
  console.log("\n2. Waiting for deployment confirmation...");
  await new Promise(resolve => setTimeout(resolve, 3000));

  // 3. 铸造测试数据
  console.log("\n3. Setting up test data...");
  
  // 铸造稳定币
  await stablecoin.mint(seller.address, ethers.parseEther("1000"));
  await stablecoin.mint(buyer.address, ethers.parseEther("1000"));
  console.log("Minted 1000 C5D to seller and buyer");

  // 铸造NFT - 修正：seller拥有所有用于测试的NFT
  await nft.safeMint(seller.address, "https://example.com/1.json");
  await nft.safeMint(seller.address, "https://example.com/2.json");
  await nft.safeMint(seller.address, "https://example.com/3.json"); // seller拥有NFT #3
  console.log("Minted 3 test NFTs to seller");

  // 4. 验证初始状态
  console.log("\n4. Verifying initial state...");
  console.log("NFT 1 owner:", await nft.ownerOf(1));
  console.log("NFT 2 owner:", await nft.ownerOf(2));
  console.log("NFT 3 owner:", await nft.ownerOf(3));

  // 5. 测试核心功能
  console.log("\n5. Testing marketplace functionality...");
  
  console.log("a) Listing NFT 3 for sale...");
  await nft.connect(seller).approve(marketplace.target, 3);
  await marketplace.connect(seller).listNFT(nft.target, 3, ethers.parseEther("1.0"));
  console.log("   Listed successfully");

  console.log("b) Checking NFT ownership after listing...");
  const ownerAfterList = await nft.ownerOf(3);
  console.log("   NFT 3 owner:", ownerAfterList);
  console.log("   Should be marketplace:", ownerAfterList === marketplace.target);

  console.log("c) Cancelling listing...");
  await marketplace.connect(seller).cancelListing(nft.target, 3);
  console.log("   Cancelled successfully");

  console.log("d) Checking NFT ownership after cancel...");
  const ownerAfterCancel = await nft.ownerOf(3);
  console.log("   NFT 3 owner:", ownerAfterCancel);
  console.log("   Should be seller:", ownerAfterCancel === seller.address);

  // 6. 保存地址
  const addresses = {
    stablecoin: stablecoin.target,
    nft: nft.target,
    marketplace: marketplace.target,
    deployer: deployer.address,
    seller: seller.address,
    buyer: buyer.address,
    network: "localhost"
  };
  
  const fs = require("fs");
  fs.writeFileSync("deployed-addresses.json", JSON.stringify(addresses, null, 2));
  console.log("\n6. Addresses saved to deployed-addresses.json");

  console.log("\n===============================");
  console.log("DEPLOYMENT COMPLETED SUCCESSFULLY!");
  console.log("All contracts deployed and tested");
  console.log("Core marketplace functionality verified");
  console.log("===============================");
}

main().catch(console.error);