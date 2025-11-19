// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// Removed Counters.sol import: use a simple uint256 counter instead of OpenZeppelin Counters

/**
 * @title COMP5521 NFT Marketplace
 * @dev A decentralized marketplace for trading NFTs using ERC20 stablecoins
 * Features: List, Buy, Cancel listings with atomic swaps
 */
contract Marketplace is ReentrancyGuard, Ownable {
    // using Counters for Counters.Counter; // replaced by simple uint256 counter below
    
    // ============ STRUCTS ============
    
    struct Listing {
        address seller;         // NFT owner who listed the item
        address nftContract;    // Address of the NFT contract
        uint256 tokenId;        // ID of the NFT
        uint256 price;          // Price in stablecoin tokens
        bool active;            // Whether the listing is active
    }
    
    // ============ STATE VARIABLES ============
    
    // Mapping from NFT contract address => tokenId => Listing
    mapping(address => mapping(uint256 => Listing)) public listings;
    
    // The ERC20 stablecoin contract used for payments
    IERC20 public stablecoin;
    
    // Marketplace fee percentage (basis points: 100 = 1%)
    uint256 public feePercentage;
    
    // Fee recipient address
    address public feeRecipient;
    
    // Counter for total listings (simple uint256 instead of Counters.Counter)
    uint256 private _listingIds;
    
    // ============ EVENTS ============
    
    event Listed(
        address indexed seller,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 price
    );
    
    event Sold(
        address indexed buyer,
        address indexed seller,
        address indexed nftContract,
        uint256 tokenId,
        uint256 price
    );
    
    event Cancelled(
        address indexed seller,
        address indexed nftContract,
        uint256 indexed tokenId
    );
    
    // ============ MODIFIERS ============
    
    modifier onlyNFTOwner(address nftContract, uint256 tokenId) {
        require(nftContract != address(0), "Invalid NFT contract address");
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not the NFT owner");
        _;
    }
    
    modifier isListed(address nftContract, uint256 tokenId) {
        require(nftContract != address(0), "Invalid NFT contract address");
        require(listings[nftContract][tokenId].active, "NFT not listed for sale");
        _;
    }
    
    modifier notListed(address nftContract, uint256 tokenId) {
        require(nftContract != address(0), "Invalid NFT contract address");
        require(!listings[nftContract][tokenId].active, "NFT already listed");
        _;
    }
    
    // ============ CONSTRUCTOR ============
    
    /**
     * @dev Initialize the marketplace with stablecoin address
     * @param _stablecoin Address of the ERC20 stablecoin contract
     */
    constructor(address _stablecoin) Ownable(msg.sender) {
        require(_stablecoin != address(0), "Invalid stablecoin address");
        stablecoin = IERC20(_stablecoin);
        feePercentage = 250; // 2.5% marketplace fee
        feeRecipient = msg.sender;
    }
    
    // ============ CORE FUNCTIONS ============
    
    /**
     * @dev List an NFT for sale
     * @param nftContract Address of the NFT contract
     * @param tokenId ID of the NFT to list
     * @param price Sale price in stablecoin tokens
     */
    function listNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external nonReentrant onlyNFTOwner(nftContract, tokenId) notListed(nftContract, tokenId) {
        require(price > 0, "Price must be greater than 0");
        
        // Transfer NFT from seller to marketplace (escrow)
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        
        // Create listing
        listings[nftContract][tokenId] = Listing({
            seller: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            active: true
        });
        
    _listingIds++;
        
        emit Listed(msg.sender, nftContract, tokenId, price);
    }
    
    /**
     * @dev Buy a listed NFT
     * @param nftContract Address of the NFT contract
     * @param tokenId ID of the NFT to buy
     */
    function buyNFT(
        address nftContract,
        uint256 tokenId
    ) external nonReentrant isListed(nftContract, tokenId) {
        Listing storage listing = listings[nftContract][tokenId];
        require(msg.sender != listing.seller, "Seller cannot buy own NFT");
        uint256 price = listing.price;
        uint256 fee = (price * feePercentage) / 10000;
        uint256 sellerProceeds = price - fee;

        // Check allowance and pull funds once to the marketplace
        require(
            stablecoin.allowance(msg.sender, address(this)) >= price,
            "Insufficient stablecoin allowance"
        );

        bool pulled = stablecoin.transferFrom(msg.sender, address(this), price);
        require(pulled, "Stablecoin transfer failed");

        // Distribute funds: fee first (if any), then seller proceeds
        if (fee > 0) {
            bool sentFee = stablecoin.transfer(feeRecipient, fee);
            require(sentFee, "Fee transfer failed");
        }
        bool sentSeller = stablecoin.transfer(listing.seller, sellerProceeds);
        require(sentSeller, "Payment to seller failed");
        
        // Transfer NFT from marketplace to buyer
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        
        // Delete listing
        delete listings[nftContract][tokenId];
        
        emit Sold(msg.sender, listing.seller, nftContract, tokenId, price);
    }
    
    /**
     * @dev Cancel an active listing
     * @param nftContract Address of the NFT contract
     * @param tokenId ID of the NFT to delist
     */
    function cancelListing(
        address nftContract,
        uint256 tokenId
    ) external nonReentrant isListed(nftContract, tokenId) {
        Listing storage listing = listings[nftContract][tokenId];
        require(msg.sender == listing.seller, "Only seller can cancel listing");
        
        // Return NFT from marketplace to seller
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        
        // Delete listing
        delete listings[nftContract][tokenId];
        
        emit Cancelled(msg.sender, nftContract, tokenId);
    }
    
    // ============ VIEW FUNCTIONS ============
    
    /**
     * @dev Get listing details for a specific NFT
     * @param nftContract Address of the NFT contract
     * @param tokenId ID of the NFT
     * @return Listing details
     */
    function getListing(address nftContract, uint256 tokenId) 
        external 
        view 
        returns (Listing memory) 
    {
        return listings[nftContract][tokenId];
    }
    
    /**
     * @dev Check if an NFT is currently listed
     * @param nftContract Address of the NFT contract
     * @param tokenId ID of the NFT
     * @return bool Whether the NFT is listed
     */
    function isNFTListed(address nftContract, uint256 tokenId) 
        external 
        view 
        returns (bool) 
    {
        return listings[nftContract][tokenId].active;
    }
    
    /**
     * @dev Get total number of listings ever created
     * @return uint256 Total listing count
     */
    function getTotalListings() external view returns (uint256) {
        return _listingIds;
    }
    
    // ============ ADMIN FUNCTIONS ============
    
    /**
     * @dev Update marketplace fee percentage
     * @param newFeePercentage New fee percentage in basis points
     */
    function setFeePercentage(uint256 newFeePercentage) external onlyOwner {
        require(newFeePercentage <= 1000, "Fee too high"); // Max 10%
        feePercentage = newFeePercentage;
    }
    
    /**
     * @dev Update fee recipient address
     * @param newFeeRecipient New address to receive fees
     */
    function setFeeRecipient(address newFeeRecipient) external onlyOwner {
        require(newFeeRecipient != address(0), "Invalid address");
        feeRecipient = newFeeRecipient;
    }
    
    /**
     * @dev Update stablecoin contract address
     * @param newStablecoin New stablecoin contract address
     */
    function setStablecoin(address newStablecoin) external onlyOwner {
        require(newStablecoin != address(0), "Invalid address");
        stablecoin = IERC20(newStablecoin);
    }
    
    /**
     * @dev Emergency function to rescue stuck NFTs (only for non-active listings)
     * @param nftContract Address of the NFT contract
     * @param tokenId ID of the NFT to rescue
     * @param to Address to send the NFT to
     */
    function rescueNFT(
        address nftContract,
        uint256 tokenId,
        address to
    ) external onlyOwner {
        require(!listings[nftContract][tokenId].active, "Cannot rescue listed NFT");
        require(to != address(0), "Invalid recipient address");
        IERC721(nftContract).transferFrom(address(this), to, tokenId);
    }
    
    /**
     * @dev Emergency function to rescue stuck ERC20 tokens
     * @param token Address of the token to rescue
     * @param to Address to send the tokens to
     * @param amount Amount of tokens to rescue
     */
    function rescueERC20(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(to != address(0), "Invalid recipient address");
        require(IERC20(token).transfer(to, amount), "ERC20 transfer failed");
    }
}