// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: LIT: Rekindle
/// @author: manifold.xyz

import "./manifold/ERC1155Creator.sol";

///////////////////////////////////////////////////////////////////
//                                                               //
//                                                               //
//    /**  _    _ _                  _ _           _             //
//     *  | |  | (_)                | | |         | |            //
//     *  | |  | |_ ______ _ _ __ __| | |     __ _| |__  ___     //
//     *  | |/\| | |_  / _` | '__/ _` | |    / _` | '_ \/ __|    //
//     *  \  /\  / |/ / (_| | | | (_| | |___| (_| | |_) \__ \    //
//     *   \/  \/|_/___\__,_|_|  \__,_\_____/\__,_|_.__/|___/    //
//     *                                                         //
//     * 🧙 https://wizardlabs.xyz/ 🧙                           //
//     */                                                        //
//                                                               //
//                                                               //
///////////////////////////////////////////////////////////////////


contract LITREKINDLE is ERC1155Creator {
    constructor() ERC1155Creator("LIT: Rekindle", "LITREKINDLE") {}
}