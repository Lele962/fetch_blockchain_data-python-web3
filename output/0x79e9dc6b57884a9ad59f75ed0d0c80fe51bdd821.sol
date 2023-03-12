// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Delineations
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////
//                    //
//                    //
//    Delineations    //
//                    //
//                    //
////////////////////////


contract DL01 is ERC721Creator {
    constructor() ERC721Creator("Delineations", "DL01") {}
}