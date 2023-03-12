// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: CJ
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////
//          //
//          //
//    CJ    //
//          //
//          //
//////////////


contract CJ is ERC721Creator {
    constructor() ERC721Creator("CJ", "CJ") {}
}