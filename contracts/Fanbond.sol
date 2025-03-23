// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Fanbond is ERC721, Ownable, ReentrancyGuard {
    // Struct to represent a fan bond
    struct Bond {
        uint256 price;
        uint256 rewardsAccumulated;
        bool isActive;
    }

    // Mapping from token ID to Bond struct
    mapping(uint256 => Bond) public bonds;

    // Counter for token IDs
    uint256 private _tokenIdCounter;

    // Event declarations
    event BondCreated(uint256 indexed tokenId, uint256 price);
    event BondPurchased(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event RewardsDistributed(uint256 indexed tokenId, uint256 amount);
    event RewardsClaimed(uint256 indexed tokenId, address indexed claimer, uint256 amount);

    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {}

    // Function to create a new fan bond
    function createBond(uint256 price) external onlyOwner {
        uint256 newTokenId = _tokenIdCounter++;
        bonds[newTokenId] = Bond(price, 0, true);
        _safeMint(owner(), newTokenId);
        emit BondCreated(newTokenId, price);
    }

    // Function to purchase a fan bond
    function purchaseBond(uint256 tokenId) external payable virtual nonReentrant {
        Bond storage bond = bonds[tokenId];
        require(bond.isActive, "Bond is not active");
        require(msg.value >= bond.price, "Insufficient payment");

        address seller = ownerOf(tokenId);
        _transfer(seller, msg.sender, tokenId);

        // Transfer the payment to the seller
        (bool success, ) = payable(seller).call{value: bond.price}("");
        require(success, "Transfer to seller failed");

        // Refund excess payment
        if (msg.value > bond.price) {
            (bool refundSuccess, ) = payable(msg.sender).call{value: msg.value - bond.price}("");
            require(refundSuccess, "Refund failed");
        }

        emit BondPurchased(tokenId, msg.sender, bond.price);
    }

    // Function to distribute rewards to a bond
    function distributeRewards(uint256 tokenId) external payable onlyOwner {
        Bond storage bond = bonds[tokenId];
        require(bond.isActive, "Bond is not active");

        bond.rewardsAccumulated += msg.value;
        emit RewardsDistributed(tokenId, msg.value);
    }

    // Function for a bond holder to claim their rewards
    function claimRewards(uint256 tokenId) public nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "Not the bond owner");
        Bond storage bond = bonds[tokenId];
        require(bond.isActive, "Bond is not active");

        uint256 rewardsToClaim = bond.rewardsAccumulated;
        bond.rewardsAccumulated = 0;

        (bool success, ) = payable(msg.sender).call{value: rewardsToClaim}("");
        require(success, "Reward transfer failed");

        emit RewardsClaimed(tokenId, msg.sender, rewardsToClaim);
    }

    // Function to deactivate a bond
    function deactivateBond(uint256 tokenId) external onlyOwner {
        Bond storage bond = bonds[tokenId];
        require(bond.isActive, "Bond is already inactive");
        bond.isActive = false;
    }

    // Override the transferFrom function to handle reward claims before transfer
    function transferFrom(address from, address to, uint256 tokenId) public override(ERC721) {
        // Claim any accumulated rewards for the current owner before transfer
        if (bonds[tokenId].rewardsAccumulated > 0) {
            claimRewards(tokenId);
        }
        super.transferFrom(from, to, tokenId);
    }

    // Override the safeTransferFrom function to handle reward claims before transfer
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override(ERC721) {
        // Claim any accumulated rewards for the current owner before transfer
        if (bonds[tokenId].rewardsAccumulated > 0) {
            claimRewards(tokenId);
        }
        super.safeTransferFrom(from, to, tokenId, data);
    }
}
