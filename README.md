NFT Marketplace - COMP5521 Project

Quick Start (5分钟部署)
1. 安装环境
bash
npm install
2. 编译合约
bash
npx hardhat compile
3. 运行测试
bash
npx hardhat test
4. 部署合约
bash
npx hardhat run scripts/deploy_new.js
5. 验证功能
bash
npx hardhat run scripts/simple-demo.js
项目结构
text
contracts/
├── Marketplace.sol       # NFT交易市场
├── COMP5521NFT.sol       # NFT代币
└── COMP5521Dollar.sol    # 稳定币
scripts/
├── deploy_new.js         # 一键部署
└── simple-demo.js        # 功能演示
test/                     # 测试文件


执行完deploy_new.js文件后检查
deployed-addresses.json 文件是否生成，包含：
三个合约地址
测试账户信息



NFT Marketplace 合约接口文档

1、COMP5521Dollar (稳定币合约)
核心功能
solidity
// 铸造代币 (仅所有者)
function mint(address to, uint256 amount) external onlyOwner
// 销毁代币
function burn(uint256 amount) external
// 批量转账
function transferBatch(address[] recipients, uint256[] amounts) external returns (bool)
视图函数
solidity
function totalSupply() external view returns (uint256)
function balanceOf(address account) external view returns (uint256)
function allowance(address owner, address spender) external view returns (uint256)

2、COMP5521NFT (NFT合约)
核心功能
solidity
// 铸造NFT (仅所有者)
function safeMint(address to, string memory tokenURI) external onlyOwner
// 批量铸造
function safeMintBatch(address to, string[] memory tokenURIs) external onlyOwner
// 设置元数据
function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyOwner
视图函数
solidity
function ownerOf(uint256 tokenId) external view returns (address)
function tokenURI(uint256 tokenId) external view returns (string memory)
function balanceOf(address owner) external view returns (uint256)
function totalSupply() external view returns (uint256)

3、Marketplace (市场合约)
核心功能
solidity
// 上架NFT
function listNFT(address nftContract, uint256 tokenId, uint256 price) external

// 购买NFT
function buyNFT(address nftContract, uint256 tokenId) external

// 取消上架
function cancelListing(address nftContract, uint256 tokenId) external
管理功能
solidity
// 设置手续费 (仅所有者)
function setFeePercentage(uint256 newFeePercentage) external onlyOwner

// 设置手续费接收地址 (仅所有者)
function setFeeRecipient(address newFeeRecipient) external onlyOwner
视图函数
solidity
function getListing(address nftContract, uint256 tokenId) external view returns (Listing memory)
function isNFTListed(address nftContract, uint256 tokenId) external view returns (bool)
function listings(address nftContract, uint256 tokenId) external view returns (Listing memory)

使用流程
准备: 用户拥有NFT和足够C5D稳定币
授权: 批准Marketplace操作NFT和稳定币
交易: 调用listNFT/buyNFT/cancelListing进行交易
验证: 通过事件和视图函数确认交易状态
*接口版本: 1.0 | 合约标准: ERC20/ERC721*



脚本功能说明
deploy_new.js - 完整部署脚本
作用：一次性部署整个项目

部署三个合约
稳定币合约 (COMP5521Dollar)
NFT合约 (COMP5521NFT)
市场合约 (Marketplace)
设置测试环境
给测试账户各铸造1000 C5D稳定币
铸造3个测试NFT给卖家账户
验证核心功能
测试NFT上架功能
测试取消上架功能
验证NFT所有权转移
保存配置
生成 deployed-addresses.json 文件
记录所有合约地址和账户信息
使用时机：第一次部署或重新部署时


simple-demo.js - 演示脚本
作用：快速演示市场功能

连接已部署的合约
读取 deployed-addresses.json 中的地址
连接到已部署的三个合约
演示基本操作
NFT上架流程
上架取消流程
验证系统正常
确认市场功能可用
输出操作结果
使用时机：部署后验证功能或演示时

简单总结
deploy_new.js = 安装系统 + 配置环境 + 测试功能

simple-demo.js = 演示已安装系统的功能

执行顺序：先运行 deploy_new.js，再运行 simple-demo.js