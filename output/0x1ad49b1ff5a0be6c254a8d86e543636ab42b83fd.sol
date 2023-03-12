// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract ERC721Tradable is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter _adamTokenIdCounter;
    Counters.Counter _eveTokenIdCounter;
    string _adamTokenUri = "ipfs://bafybeibdybwg373zxqukyswyjvydj2ywskd3zarhbx6rktcezej2svyaya/";
    string _eveTokenUri = "ipfs://bafybeibsepzqed7gxo4idxbnygetkjfxgnfp25a4ad6rh5rc4rld2uxyn4/";
    Counters.Counter _supplyCounterForWhitelist;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        _adamTokenIdCounter.increment();
        _eveTokenIdCounter.increment();
        _supplyCounterForWhitelist.increment();
    }

    function totalSupply() public view override returns (uint256) {
        return _adamTokenIdCounter.current() + _eveTokenIdCounter.current() - 2;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function tokenURI(uint256 _tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        if (SafeMath.mod(_tokenId, 2) == 0) {
            return string(abi.encodePacked(_eveTokenUri, SafeMath.div(_tokenId, 2).toString()));
        } else {
            return string(abi.encodePacked(_adamTokenUri, SafeMath.div(_tokenId + 1, 2).toString()));
        }
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}

contract AdamAndEve is ERC721Tradable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    uint256 adamMaxSupply = 400;
    uint256 eveMaxSupply = 1500;
    uint256 whitelistSupply;

    mapping(address => bool) whitelistedAddresses;

    bool canMint = true;
    bool canMintByWhitelistUser = true;

    uint256 tokenPrice = 40000000000000000; // 0.04 ETH
    uint256 tokenPriceForWhitelistUser = 20000000000000000; // 0.02 ETH

    constructor(
        uint256 _whitelistSupply
    )   ERC721Tradable("Adam&Eve", unicode"♂❤♀") {
        whitelistSupply = _whitelistSupply;
    }

    function addUsersToWhitelist(address[] memory users) public onlyOwner {
        for(uint256 i; i<users.length; i++){
            whitelistedAddresses[users[i]] = true; 
        }
    }
    function verifyUserInWhitelist(address _whitelistedAddress) public view returns(bool) {
        return whitelistedAddresses[_whitelistedAddress];
    }

    function setWhitelistSupply(uint256 _newWhitelistSupply) public onlyOwner {
        whitelistSupply = _newWhitelistSupply;
    }

    function getWhitelistSupply() public view returns(uint256) {
        return whitelistSupply;
    }

    function getSupplyCounterForWhitelist() public view returns(uint256) {
        return _supplyCounterForWhitelist.current() - 1;
    }

    function setAdamMaxSupply(uint256 _newMaxSuppply) public onlyOwner {
        adamMaxSupply = _newMaxSuppply;
    }

    function setEveMaxSupply(uint256 _newMaxSuppply) public onlyOwner {
        eveMaxSupply = _newMaxSuppply;
    }

    function newAdam(uint256 _amount) public payable returns(uint256) {
        require(canMint, "Market is not started yet");
        require(_amount > 0, "Amount must be bigger than 0");
        require(_adamTokenIdCounter.current() - 1 + _amount <= adamMaxSupply, "Sold out");
        require(msg.value >= tokenPrice.mul(_amount), "Insufficient balance");

        uint256 mintedId;
        for(uint256 i; i<_amount; i++) {
            mintedId =  SafeMath.sub(SafeMath.mul(_adamTokenIdCounter.current(), 2), 1);
            _safeMint(msg.sender, mintedId);
            _adamTokenIdCounter.increment();
        }

        return mintedId;
    }

    function newAdamForWhitelist(uint256 _amount) public payable returns(uint256) {
        require(canMintByWhitelistUser, "Market for whitelist user is not started yet");
        require(whitelistedAddresses[msg.sender], "You need to be whitelisted");
        require(_amount > 0, "Amount must be bigger than 0");
        require(_supplyCounterForWhitelist.current() - 1 + _amount <= whitelistSupply, "Sold out for whitelist user");
        require(_adamTokenIdCounter.current() - 1 + _amount <= adamMaxSupply, "Sold out");
        require(msg.value >= tokenPriceForWhitelistUser.mul(_amount), "Insufficient balance");

        uint256 mintedId;  
        
        for(uint256 i; i<_amount; i++) {
            mintedId =  SafeMath.sub(SafeMath.mul(_adamTokenIdCounter.current(), 2), 1);
            _safeMint(msg.sender, mintedId);
            _supplyCounterForWhitelist.increment();
            _adamTokenIdCounter.increment();
        }

        return mintedId;
    }

    function newEve(uint256 _amount) public payable returns(uint256) {
        require(canMint, "Market is not started yet");
        require(_amount > 0, "Amount must be bigger than 0");
        require(_eveTokenIdCounter.current() - 1 + _amount <= eveMaxSupply, "Sold out");
        require(msg.value >= tokenPrice.mul(_amount), "Insufficient balance");

        uint256 mintedId;
        for(uint256 i; i<_amount; i++) {
            mintedId =  SafeMath.mul(_eveTokenIdCounter.current(), 2);
            _safeMint(msg.sender, mintedId);
            _eveTokenIdCounter.increment();
        }

        return mintedId;
    }

    function newEveForWhitelist(uint256 _amount) public payable returns(uint256) {
        require(canMintByWhitelistUser, "Market for whitelist user is not started yet");
        require(whitelistedAddresses[msg.sender], "You need to be whitelisted");
        require(_amount > 0, "Amount must be bigger than 0");
        require(_supplyCounterForWhitelist.current() - 1 + _amount <= whitelistSupply, "Sold out for whitelist user");
        require(_eveTokenIdCounter.current() - 1 + _amount <= eveMaxSupply, "Sold out");
        require(msg.value >= tokenPriceForWhitelistUser.mul(_amount), "Insufficient balance");

        uint256 mintedId;  
        
        for(uint256 i; i<_amount; i++) {
            mintedId =  SafeMath.mul(_eveTokenIdCounter.current(), 2);
            _safeMint(msg.sender, mintedId);
            _supplyCounterForWhitelist.increment();
            _eveTokenIdCounter.increment();
        }

        return mintedId;
    }

    function setPrice(uint256 _newPrice) public onlyOwner {
        tokenPrice = _newPrice;
    }

    function setPriceForWhitelistUser(uint256 _newPrice) public onlyOwner {
        tokenPriceForWhitelistUser = _newPrice;
    }

    function adjustAdamUri(string memory newUri) public onlyOwner {
        _adamTokenUri = newUri;
    }

    function adjustEveUri(string memory newUri) public onlyOwner {
        _eveTokenUri = newUri;
    }

    function enableMint(uint256 _switcher) public onlyOwner {
        if(_switcher == 0) {
            canMint = !canMint;
        } else if(_switcher == 1) {
            canMintByWhitelistUser = !canMintByWhitelistUser;
        }
    }

    function tokensOfOwner(address _owner) external view returns (uint256[] memory) {
		uint256 tokenCount = balanceOf(_owner);
		if (tokenCount == 0) return new uint256[](0);
		else {
			uint256[] memory result = new uint256[](tokenCount);
			uint256 index;
			for (index = 0; index < tokenCount; index++) {
				result[index] = tokenOfOwnerByIndex(_owner, index);
			}
			return result;
		}
	}

    function withdrawFunds() public onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}
}