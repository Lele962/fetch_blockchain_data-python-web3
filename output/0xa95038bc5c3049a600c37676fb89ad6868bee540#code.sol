// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: THE TURTLE
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////////////////
//                                //
//                                //
//    _______ _______  ______     //
//      | |     | |   | |         //
//      | |     | |   | |----     //
//      |_|     |_|   |_|____     //
//                                //
//                                //
//                                //
////////////////////////////////////


contract TTE is ERC721Creator {
    constructor() ERC721Creator("THE TURTLE", "TTE") {}
}