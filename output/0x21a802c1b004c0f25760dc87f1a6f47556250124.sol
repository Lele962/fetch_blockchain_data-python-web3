// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: the culture
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

///////////////////////////////////////////////////////////////////////////////////////////
//                                                                                       //
//                                                                                       //
//                 ____________________________________________________                  //
//                /                                                    \                 //
//               |    ______________________________________________    |                //
//               |||||                                              |||||                //
//               |||||                                              |||||                //
//               |||||                                              |||||                //
//               |||||                                              |||||                //
//               |||||   _   _                  _ _                 |||||                //
//               |||||  | |_| |_ ___    ___ _ _| | |_ _ _ ___ ___   |||||                //
//               |||||  |  _|   | -_|  |  _| | | |  _| | |  _| -_|  |||||                //
//               |||||  |_| |_|_|___|  |___|___|_|_| |___|_| |___|  |||||                //
//               |||||                                              |||||                //
//               |||||              by: xxes                        |||||                //
//               |||||                                              |||||                //
//               |||||                                              |||||                //
//               |||||                                              |||||                //
//               |||||                                              |||||                //
//               |||||                                              |||||                //
//               |||||______________________________________________|||||                //
//               |                                                      |                //
//               | ____________________________________________________ |                //
//               \   _________________________________________________  /                //
//                \ __________________________________________________ /                 //
//                |_-'    .-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.  --- `.  '_|                 //
//              _-' .-.-. .---.-.-.-.-.-.-.-.-.-.-.-.-.-.-.--.  .-.-.-. `-_              //
//           _-' .-.-.-. .---.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-`__`. .-.-.-.-. `-_           //
//        _-' .-.-.-.-. .-----.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-----. .-.-.-.-.-. `-_        //
//     _-' .-.-.-.-.-. .---.-. .-------------------------. .-.---. .---.-.-.--.  `-_     //
//    :-----------------------------------------------------------------------------:    //
//    `----._.---------------------------------------------------------------._.----'    //
//                                                                                       //
//                                                                                       //
//                                                                                       //
//                                                                                       //
///////////////////////////////////////////////////////////////////////////////////////////


contract CULTURE is ERC721Creator {
    constructor() ERC721Creator("the culture", "CULTURE") {}
}