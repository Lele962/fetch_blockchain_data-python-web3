// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: COLLABS
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

/////////////////////////////////////////////////
//                                             //
//                                             //
//                                             //
//     ____   ___     _     _    _    ____     //
//    |___ \ / _ \   | |   | |  / \  ( __ |    //
//        | | | | |  | |   | | / _ \ / _  |    //
//     ___| | |_| ___| |___| |/ ___ | (_| |    //
//    |____/ \___|_____|_____/_/   \_\____|    //
//                                             //
//                                             //
//                                             //
//                                             //
/////////////////////////////////////////////////


contract COLL is ERC1155Creator {
    constructor() ERC1155Creator("COLLABS", "COLL") {}
}