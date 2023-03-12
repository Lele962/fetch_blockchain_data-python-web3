// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 	// ERC20 interface
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; 	// ERC721
import "@openzeppelin/contracts/access/Ownable.sol"; 		// OZ: Ownable
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 	// OZ: ReentrancyGuard 

contract RedPanda is ERC721, ReentrancyGuard, Ownable {
    using Strings for string;
    using Strings for uint256;

    uint256[5] public mintFeeETH = [0.014*1e18, 0.016*1e18, 0.02*1e18, 0.032*1e18, 0.04*1e18];
    uint256[5] public mintFeeESG = [35*1e18, 40*1e18, 50*1e18, 80*1e18, 100*1e18];
    uint256[5] public nftCurrentIds = [1,1001,2001,3001,4001]; 
    uint256[5] public nftCapIds = [1000,2000,3000,4000,5000]; 
    IERC20 public immutable esgToken;
    address private donationWallet;
    address private devWallet;
    address private rewardWallet; 
    address private deadWallet; 

    /**
     * Events
     */
    event BuyWithETH(address indexed account, uint256 tokenId, uint256 cost);
    event BuyWithESG(address indexed account, uint256 tokenId, uint256 cost);

    constructor(address _esgToken)
        ERC721("Red Panda NFT", "Red Panda NFT")
    {  
	    esgToken = IERC20(_esgToken);
        donationWallet = 0x83C35e0eFaa20c31C3164453D84c73a08Bb775fc;
        devWallet = 0x9AEFf3996E54D5661a209bE2fd571141A363D68d;
        rewardWallet = 0x55ae7ceEaba972F966b07Af1ebC4D62281dc0257;
        deadWallet = 0x000000000000000000000000000000000000dEaD;
    }

    function mintWithETH(uint256 level) public payable nonReentrant
    {
        require(level > 0 && level <= 5, "exceeds bounds of level");
        uint index = level -1;
	    require(msg.value >= mintFeeETH[index], "INSUFFICIENT MINT COST ETH");

	    uint256 newId = nftCurrentIds[index]; 
	    require(newId <= nftCapIds[index] , "tokenId exceeds limit");
	    require(!_exists(newId), "NFT minted.");
        nftCurrentIds[index] = newId + 1;
        _safeMint(msg.sender, newId);
        emit BuyWithETH(msg.sender, newId, mintFeeETH[index]);

        uint256 remaining = msg.value - mintFeeETH[index];
        if(remaining > 0)
            payable(msg.sender).transfer(remaining);
        payable(donationWallet).transfer(mintFeeETH[index] / 2 );
        payable(devWallet).transfer(mintFeeETH[index] / 10  );
        payable(rewardWallet).transfer(mintFeeETH[index] * 2 / 5  );
    }

    function mintWithESG(uint256 level, uint256 amount) public nonReentrant
    {
        require(level > 0 && level <= 5, "exceeds bounds of level");
        uint index = level -1;
	    require(amount >= mintFeeESG[index], "INSUFFICIENT MINT COST ESG");
	    require(esgToken.balanceOf(msg.sender) >= amount, "INSUFFICIENT ESG BALANCE");
	    esgToken.transferFrom(msg.sender, address(this), mintFeeESG[index]);

	    uint256 newId = nftCurrentIds[index]; 
	    require(newId <= nftCapIds[index] , "tokenId exceeds limit");
	    require(!_exists(newId), "NFT minted.");
        nftCurrentIds[index] = newId + 1;
        _safeMint(msg.sender, newId);
        emit BuyWithESG(msg.sender, newId, mintFeeETH[index]);
	    esgToken.transfer(donationWallet, mintFeeESG[index] / 2);
	    esgToken.transfer(devWallet, mintFeeESG[index] / 10);
	    esgToken.transfer(rewardWallet, mintFeeESG[index] * 7 / 20);
        esgToken.transfer(deadWallet, mintFeeESG[index] / 20);
    }

    /// @notice Returns metadata about a token (depending on randomness reveal status)
    /// @dev Partially implemented, returns only example string of randomness-dependent content
    function tokenURI(uint256 tokenId) override public pure returns (string memory) {
        string[2] memory parts;

        parts[0] = 'https://econft.market/service/panda_meta.php?id=';

        parts[1] = string(tokenId.toString());

        string memory output = string(abi.encodePacked(parts[0], parts[1]));

        return output;
    }

    function tokenURIExtend(uint256 tokenId) public pure returns (string memory, string memory) {

        string[3] memory parts;

        parts[0] = 'https://econft.market';

        parts[1] = '/service/panda_meta.php?id=';

        parts[2] = string(tokenId.toString());

        string memory api = string(abi.encodePacked(parts[1], parts[2]));

        return (parts[0], api);
    }

   function _setMintETHPrice(uint index, uint256 price) public onlyOwner {
       require(index < 5, "invalid index");
       mintFeeETH[index] = price;
   }

   function _setMintESGPrice(uint index, uint256 price) public onlyOwner {
       require(index < 5, "invalid index");
       mintFeeESG[index] = price;
   }

   function _withdrawERC20Token(address token) public onlyOwner {
	    uint256 amount = IERC20(token).balanceOf(address(this));
	    if(amount > 0)
		    IERC20(token).transfer(owner(), amount);
   }

   function _withdrawETH() public onlyOwner {
	    uint256 amount = address(this).balance; 
	    if(amount > 0)
		    payable(owner()).transfer(amount);
   }
}