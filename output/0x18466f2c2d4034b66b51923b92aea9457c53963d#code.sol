// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Lones and bones by Marrock
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

///////////////////////
//                   //
//                   //
//    Lones&Bones    //
//                   //
//                   //
///////////////////////


contract LAB is ERC721Creator {
    constructor() ERC721Creator("Lones and bones by Marrock", "LAB") {}
}