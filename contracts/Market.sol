// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "./IMarket.sol";

contract Market is IMarket {

    using SafeMath for uint256;

    address private mediaAddress;

    mapping(uint256 => Bid[]) private tokenBidsList;
    mapping(uint256 => mapping(address => Bid)) private allBidders;

    modifier onlyMedia {
        require(msg.sender == mediaAddress, "Market: Unauthorized access!");
        _;
    }

    receive() external payable {}
    fallback() external payable {}

    // It should only called once
    function configureMedia(address _mediaAddress) external override {
        require(mediaAddress == address(0), "Market: Already assigned!");
        require(_mediaAddress != address(0), "Market: Invalid address");

        mediaAddress = _mediaAddress;
    }

    // Create new bid on the token
    function setBid(
        uint256 _tokenId,
        address _bidder,
        uint256 _bidAmount
    ) external payable override onlyMedia {
        require(
            allBidders[_tokenId][_bidder].amount == 0,
            "Market: Already Bided!"
        );

        if (tokenBidsList[_tokenId].length != 0) {
            require(
                _bidAmount > tokenBidsList[_tokenId][tokenBidsList[_tokenId].length - 1].amount,
                "Market: Bid amount should higher than last bid"
            );
        }
        Bid memory _newBid = Bid(_bidder, _bidAmount);
        tokenBidsList[_tokenId].push(_newBid);
        allBidders[_tokenId][_bidder] = _newBid;
    }

    function removeBid(uint256 _tokenId) external override {
        // TODO: Complete function 
    }
    
    function acceptBid(uint256 _tokenId, address _bidder) external override {
        // TODO: Complete function 
    }
    
    function transferShares(uint256 _amount) external override {
        // TODO: Complete function 
    }
}
