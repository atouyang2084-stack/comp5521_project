// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title COMP5521 Dollar
 * @dev ERC20 stablecoin pegged to HKD (simulated 1:1 peg)
 */
contract COMP5521Dollar is ERC20, Ownable {
    
    // ============ EVENTS ============
    
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    
    // ============ CONSTRUCTOR ============
    
    constructor() ERC20("COMP5521 Dollar", "C5D") Ownable(msg.sender) {
        // Initial supply: 1,000,000 C5D (simulating initial liquidity)
        _mint(msg.sender, 1000000 * 10**decimals());
    }
    
    // ============ MINTING FUNCTIONS ============
    
    /**
     * @dev Mint new tokens (only owner)
     * @param to Address to receive the tokens
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than 0");
        
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }
    
    /**
     * @dev Batch mint tokens to multiple addresses (only owner)
     * @param recipients Array of recipient addresses
     * @param amounts Array of amounts to mint
     */
    function mintBatch(address[] memory recipients, uint256[] memory amounts) public onlyOwner {
        require(recipients.length == amounts.length, "Arrays length mismatch");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            mint(recipients[i], amounts[i]);
        }
    }
    
    // ============ BURNING FUNCTIONS ============
    
    /**
     * @dev Burn tokens from caller's account
     * @param amount Amount of tokens to burn
     */
    function burn(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
    
    /**
     * @dev Burn tokens from a specific account (only owner)
     * @param account Address to burn tokens from
     * @param amount Amount of tokens to burn
     */
    function burnFrom(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "Invalid account address");
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(account) >= amount, "Insufficient balance");
        
        _burn(account, amount);
        emit TokensBurned(account, amount);
    }
    
    // ============ TRANSFER FUNCTIONS ============
    
    /**
     * @dev Transfer tokens to multiple addresses in one transaction
     * @param recipients Array of recipient addresses
     * @param amounts Array of amounts to transfer
     */
    function transferBatch(address[] memory recipients, uint256[] memory amounts) public returns (bool) {
        require(recipients.length == amounts.length, "Arrays length mismatch");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(transfer(recipients[i], amounts[i]), "Transfer failed");
        }
        
        return true;
    }
    
    // ============ VIEW FUNCTIONS ============
    
    /**
     * @dev Get contract version
     * @return string Version string
     */
    function version() public pure returns (string memory) {
        return "1.0.0";
    }
    
    /**
     * @dev Get total supply in readable format (without decimals)
     * @return uint256 Total supply
     */
    function totalSupplyReadable() public view returns (uint256) {
        return totalSupply() / 10**decimals();
    }
    
    /**
     * @dev Get balance in readable format (without decimals)
     * @param account Address to check balance for
     * @return uint256 Balance
     */
    function balanceOfReadable(address account) public view returns (uint256) {
        return balanceOf(account) / 10**decimals();
    }
}