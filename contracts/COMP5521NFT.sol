// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title COMP5521 NFT
 * @dev ERC721 compliant NFT contract for digital collectibles
 */
contract COMP5521NFT is ERC721, Ownable {
    
    // ============ STATE VARIABLES ============
    
    uint256 private _tokenIdCounter;
    string private _baseTokenURI;
    
    // Mapping from token ID to token URI
    mapping(uint256 => string) private _tokenURIs;
    
    // ============ EVENTS ============
    
    event TokenMinted(address indexed to, uint256 indexed tokenId, string uri);
    
    // ============ CONSTRUCTOR ============
    
    constructor() ERC721("COMP5521 NFT", "C5NFT") Ownable(msg.sender) {
        _tokenIdCounter = 0;
        _baseTokenURI = "";
    }
    
    // ============ MINTING FUNCTIONS ============
    
    /**
     * @dev Mint a new NFT to the specified address (only owner)
     * @param to Address to receive the NFT
     * @param uri Metadata URI for the NFT
     */
    function safeMint(address to, string memory uri) public onlyOwner {
        require(to != address(0), "Invalid recipient address");
        require(bytes(uri).length > 0, "Token URI cannot be empty");
        
        _tokenIdCounter += 1;
        uint256 tokenId = _tokenIdCounter;
        
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        emit TokenMinted(to, tokenId, uri);
    }
    
    /**
     * @dev Batch mint multiple NFTs (only owner)
     * @param to Address to receive the NFTs
     * @param tokenURIs Array of metadata URIs
     */
    function safeMintBatch(address to, string[] memory tokenURIs) public onlyOwner {
        require(to != address(0), "Invalid recipient address");
        
        for (uint256 i = 0; i < tokenURIs.length; i++) {
            safeMint(to, tokenURIs[i]);
        }
    }
    
    // ============ METADATA FUNCTIONS ============
    
    /**
     * @dev Get the token URI for a specific token ID
     * @param tokenId ID of the token
     * @return string Token URI
     */
    function tokenURI(uint256 tokenId) 
        public 
        view 
        virtual 
        override 
        returns (string memory) 
    {
    // Revert if token doesn't exist
    _requireOwned(tokenId);

    string memory _tokenURI = _tokenURIs[tokenId];
        
        // If base URI is set, concatenate base URI and token URI
        if (bytes(_baseTokenURI).length > 0) {
            return string(abi.encodePacked(_baseTokenURI, _tokenURI));
        }
        
        return _tokenURI;
    }
    
    /**
     * @dev Set the token URI for a specific token (only owner)
     * @param tokenId ID of the token
     * @param _tokenURI New token URI
     */
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
        _requireOwned(tokenId);
        _tokenURIs[tokenId] = _tokenURI;
    }
    
    /**
     * @dev Set base token URI for all tokens (only owner)
     * @param baseURI Base URI
     */
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }
    
    // ============ VIEW FUNCTIONS ============
    
    /**
     * @dev Get total number of minted tokens
     * @return uint256 Total token count
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }
    
    /**
     * @dev Check if a token exists
     * @param tokenId ID of the token
     * @return bool Whether the token exists
     */
    function exists(uint256 tokenId) public view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
    
    /**
     * @dev Get tokens owned by an address
     * @param owner Address to query
     * @return uint256[] Array of token IDs
     */
    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        require(owner != address(0), "Invalid owner address");
        
        uint256 tokenCount = balanceOf(owner);
        uint256[] memory tokenIds = new uint256[](tokenCount);
        
        uint256 currentTokenId = 1;
        uint256 ownedTokenIndex = 0;
        
        while (ownedTokenIndex < tokenCount && currentTokenId <= _tokenIdCounter) {
            // check token existence via _ownerOf (returns 0 if non-existent)
            if (_ownerOf(currentTokenId) != address(0) && ownerOf(currentTokenId) == owner) {
                tokenIds[ownedTokenIndex] = currentTokenId;
                ownedTokenIndex++;
            }
            currentTokenId++;
        }
        
        return tokenIds;
    }
    
    // ============ INTERNAL FUNCTIONS ============
    
    /**
     * @dev Set token URI for a token
     * @param tokenId ID of the token
     * @param _tokenURI Token URI
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _requireOwned(tokenId);
        _tokenURIs[tokenId] = _tokenURI;
    }
}