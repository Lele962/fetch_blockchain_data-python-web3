// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: M-Duos
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

/////////////////////////////////////////////////
//                                             //
//                                             //
//                                             //
//     \\\    /// __   \\\    ///              //
//     ((O)  (O))/' \  ((O)  (O))(O)-.         //
//      | \  / | " ||   | \  / |(_.-. \        //
//      ||\\//||   ||   ||\\//||     )/        //
//      || \/ ||   ||   || \/ ||    //         //
//      ||    ||  _||_  ||    ||   /(____;     //
//     (_/    \_)(_/\_)(_/    \_) (____.-'     //
//                                             //
//                                             //
//                                             //
/////////////////////////////////////////////////


contract M1M2 is ERC721Creator {
    constructor() ERC721Creator("M-Duos", "M1M2") {}
}