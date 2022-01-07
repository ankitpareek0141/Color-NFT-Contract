// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMarket {
    
    struct Bid {
        address bidder;
        uint256 amount;
    }
    
    function setBid(uint256 _tokenId, address _bidder, uint256 _amount) external payable;
    
    function removeBid(uint256 _tokenId) external;
    
    function acceptBid(uint256 _tokenId, address _bidder) external;
    
    function transferShares(uint256 _amount) external;

    function configureMedia(address _mediaAddress) external;
}