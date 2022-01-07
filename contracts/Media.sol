// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "./IMarket.sol";

contract ColorNFT is ERC721 {
    
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
    struct Token {
        string name;
        string uri;
        address creator;
        address owner;
        uint256 price;
        bool auction;
    }
    
    uint256 _creatorPercentage = 1000; // 10%
    uint256 _adminPercentage = 500; // 5%
    Counters.Counter private tokenId;
    IMarket private marketContract;
    
    mapping(uint256 => Token) private allTokens;
    mapping(string => bool) private uniqueImgUri;
    
    event MintToken(
        string name, 
        string uri, 
        address creator,
        address owner,
        uint256 price
    );
    
    event BuyToken(
        uint256 tokenId,
        address seller,
        address buyer
    );
    
    constructor(IMarket _marketContract) ERC721("Color", "COLOR") {
        marketContract = _marketContract;
    }
    
    receive()external payable {}
    fallback()external payable {}
    
    function mintToken(
        string memory _name, 
        string memory _uri, 
        uint _price, 
        address _creator, 
        bool _forAuction
    ) external {
        require(bytes(_name).length > 0, "ColorNFT: Name should not empty!");
        require(bytes(_uri).length > 0, "ColorNFT: Uri should not empty!");
        require(uniqueImgUri[_uri] == false, "ColorNFT: Art already minted!");
        tokenId.increment();
        uint256 _tokenId = tokenId.current();
        allTokens[_tokenId] = Token(_name, _uri, msg.sender, msg.sender, _price, _forAuction);
        uniqueImgUri[_uri] = true;
        _mint(msg.sender, _tokenId);
        setApprovalForAll(address(marketContract), true);
        emit MintToken(
            _name, 
            _uri, 
            _creator,
            msg.sender,
            _price
        );
    }
    
    function buyToken(uint _tokenId, address _owner)external payable {
        require(_tokenId <= tokenId.current(), "ColorNFT: Invalid Token Id!");
        Token memory token = allTokens[_tokenId];
        require(token.auction == false, "ColorNFT: Direct purchase not allowed!");
        require(token.price == msg.value, "ColorNFT: Insufficient amount!");
        require(token.owner != msg.sender && token.owner == _owner, "ColorNFT: Invalid buy!");
        token.owner = msg.sender;
        allTokens[_tokenId] = token;
        
        (uint256 _creatorAmount, uint256 _sellerAmount) = divideShare(msg.value);
        payable(token.creator).transfer(_creatorAmount);
        payable(_owner).transfer(_sellerAmount);
        
        emit BuyToken(
            _tokenId,
            _owner,
            msg.sender
        );
    }
    
    function setBid(uint256 _tokenId, uint256 _bidAmount, address _bidder) external payable returns(bool){
        require(ownerOf(_tokenId) != msg.sender, "ColorNFT: Owner cannot bid!");
        require(allTokens[_tokenId].auction == true, "ColorNFT: Not for auction!");
        require(_bidAmount != 0, "ColorNFT: Cannot bid with zero amount!");
        require(_bidder != address(0), "ColorNFT: Invalid bidder address!");
        
        payable(address(marketContract)).transfer(msg.value);
        marketContract.setBid(_tokenId, _bidder, _bidAmount);
        return true;
    }
    
    function divideShare(uint256 _amount)private view returns(uint256, uint256) {
        uint256 _adminAmount = _amount.mul(_adminPercentage).div(10000);
        uint256 _creatorAmount = _amount.mul(_creatorPercentage).div(10000);
        uint256 _sellerAmount = _amount.sub(_adminAmount.add(_creatorAmount));
        
        return (_creatorAmount, _sellerAmount);
    }
    
    function withdrawFunds()external {
        payable(address(msg.sender)).transfer(address(this).balance);
    }
    
    function adminFunds() external view returns(uint256) {
        return address(this).balance;
    }
}
