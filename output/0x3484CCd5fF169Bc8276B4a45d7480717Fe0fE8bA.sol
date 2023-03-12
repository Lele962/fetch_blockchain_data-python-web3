// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "library/contracts/token/ERC721MaxSupply.sol";
import "library/contracts/sell/BasicSellMultiple.sol";
import "library/contracts/access/AbstractWhitelist.sol";

contract Locations is ERC721MaxSupply, BasicSellMultiple, AbstractWhitelist {
  using SafeMath for uint256;

  mapping(address => uint256) public minted;
  uint256 public numFreeMints;

  address private dev;
  uint256 private _maxMintsPerAddr;

  constructor(
    uint256 maxSupply_,
    uint256 numFreeMints_,
    uint256 maxMintsPerAddr_
  )
    ERC721MaxSupply("Locations", "LOC", maxSupply_, "https://test.com/")
    BasicSellMultiple(0.002 ether)
  {
    numFreeMints = numFreeMints_;
    _maxMintsPerAddr = maxMintsPerAddr_;
  }

  function mintFree(uint256 amount_) external isPublic {
    require(totalSupply().add(amount_) <= numFreeMints, "free mint over");
    require(minted[msg.sender].add(amount_) <= _maxMintsPerAddr, "free mint used up");

    minted[msg.sender] += amount_;
    for (uint256 i = 0; i < amount_; ++i) _safeMint(msg.sender);
  }

  function mintPublic(uint256 amount_) external payable isPublic isPaymentOk(amount_) {
    require(totalSupply() >= numFreeMints, "free mint not over");
    for (uint256 i = 0; i < amount_; ++i) _safeMint(msg.sender);
  }

  function mintOwner(address receiver_, uint256 amount_) external onlyOwner {
    for (uint256 i = 0; i < amount_; ++i) _safeMint(receiver_);
  }

  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }
}