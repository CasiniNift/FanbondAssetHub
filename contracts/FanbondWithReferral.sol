// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Fanbond.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract FanbondWithReferral is Fanbond {
    // Referral fee percentage (in basis points, e.g., 250 = 2.5%)
    uint256 public referralFeePercent;

    // Mapping to store referrers for each address
    mapping(address => address) public referrers;

    // Mapping to store total referral rewards for each referrer
    mapping(address => uint256) public referralRewards;

    // Event to log referral rewards
    event ReferralReward(address indexed referrer, address indexed buyer, uint256 amount);

    constructor(
        string memory name,
        string memory symbol,
        uint256 _referralFeePercent
    ) Fanbond(name, symbol) {
        require(_referralFeePercent <= 1000, "Referral fee cannot exceed 10%");
        referralFeePercent = _referralFeePercent;
    }

    // Function to set a referrer
    function setReferrer(address referrer) external {
        require(referrer != msg.sender, "Cannot refer yourself");
        require(referrer != address(0), "Invalid referrer address");
        require(referrers[msg.sender] == address(0), "Referrer already set");

        referrers[msg.sender] = referrer;
    }

    // Override the purchaseBond function to include referral logic
    function purchaseBond(uint256 tokenId) external payable override nonReentrant {
        Bond storage bond = bonds[tokenId];
        require(bond.isActive, "Bond is not active");
        require(msg.value >= bond.price, "Insufficient payment");

        address seller = ownerOf(tokenId);
        _transfer(seller, msg.sender, tokenId);

        // Calculate referral fee
        uint256 referralFee = (bond.price * referralFeePercent) / 10000;
        uint256 sellerAmount = bond.price - referralFee;

        // Transfer the payment to the seller
        (bool sellerSuccess, ) = payable(seller).call{value: sellerAmount}("");
        require(sellerSuccess, "Transfer to seller failed");

        // Handle referral reward
        address referrer = referrers[msg.sender];
        if (referrer != address(0)) {
            referralRewards[referrer] += referralFee;
            emit ReferralReward(referrer, msg.sender, referralFee);

            (bool referrerSuccess, ) = payable(referrer).call{value: referralFee}("");
            require(referrerSuccess, "Transfer to referrer failed");
        } else {
            // If no referrer, send the referral fee to the contract owner
            (bool ownerSuccess, ) = payable(owner()).call{value: referralFee}("");
            require(ownerSuccess, "Transfer to owner failed");
        }

        // Refund excess payment
        uint256 excess = msg.value - bond.price;
        if (excess > 0) {
            (bool refundSuccess, ) = payable(msg.sender).call{value: excess}("");
            require(refundSuccess, "Refund failed");
        }

        emit BondPurchased(tokenId, msg.sender, bond.price);
    }

    // Function to update referral fee percentage (only owner)
    function updateReferralFeePercent(uint256 _newReferralFeePercent) external onlyOwner {
        require(_newReferralFeePercent <= 1000, "Referral fee cannot exceed 10%");
        referralFeePercent = _newReferralFeePercent;
    }

    // Function to get total referral rewards for a referrer
    function getTotalReferralRewards(address referrer) external view returns (uint256) {
        return referralRewards[referrer];
    }
}
