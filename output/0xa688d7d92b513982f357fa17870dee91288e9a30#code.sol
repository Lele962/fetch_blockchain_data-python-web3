// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Mint Kasper
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

/////////////////////
//                 //
//                 //
//    bork bork    //
//                 //
//                 //
/////////////////////


contract borkasper is ERC1155Creator {
    constructor() ERC1155Creator("Mint Kasper", "borkasper") {}
}