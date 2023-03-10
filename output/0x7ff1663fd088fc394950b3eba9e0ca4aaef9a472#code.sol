// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Checks - Arcade Edition
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                          //
//                                                                                                          //
//                                                                                                          //
//      ______  __    __   _______   ______  __  ___      _______.   .______   ____    ____                 //
//     /      ||  |  |  | |   ____| /      ||  |/  /     /       |   |   _  \  \   \  /   /                 //
//    |  ,----'|  |__|  | |  |__   |  ,----'|  '  /     |   (----`   |  |_)  |  \   \/   /                  //
//    |  |     |   __   | |   __|  |  |     |    <       \   \       |   _  <    \_    _/                   //
//    |  `----.|  |  |  | |  |____ |  `----.|  .  \  .----)   |      |  |_)  |     |  |                     //
//     \______||__|  |__| |_______| \______||__|\__\ |_______/       |______/      |__|                     //
//                                                                                                          //
//         _______. __    __  .______    _______ .______             __       ___       ______  __  ___     //
//        /       ||  |  |  | |   _  \  |   ____||   _  \           |  |     /   \     /      ||  |/  /     //
//       |   (----`|  |  |  | |  |_)  | |  |__   |  |_)  |          |  |    /  ^  \   |  ,----'|  '  /      //
//        \   \    |  |  |  | |   ___/  |   __|  |      /     .--.  |  |   /  /_\  \  |  |     |    <       //
//    .----)   |   |  `--'  | |  |      |  |____ |  |\  \----.|  `--'  |  /  _____  \ |  `----.|  .  \      //
//    |_______/     \______/  | _|      |_______|| _| `._____| \______/  /__/     \__\ \______||__|\__\     //
//                                                                                                          //
//                                                                                                          //
//                                                                                                          //
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract CHECKS is ERC721Creator {
    constructor() ERC721Creator("Checks - Arcade Edition", "CHECKS") {}
}