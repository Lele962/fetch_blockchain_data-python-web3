// SPDX-License-Identifier: MIT

//                      ..........  ...          ..............................      
//                    [email protected]@@@@@@@@@@@@@@@%:       :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@=    
//                   [email protected]@@@@@@@@@@@@@@@@@@.       *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%    
//                  .%@@@@@@@@@@@@@@@@@@@@       [email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+    
//                  #@@@@@@@@@@@@@@@@@@@@@+       [email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@     
//                 [email protected]@@@@@@@@@@@@@@@@@@@@@@:       @@@@@@@@@@@@@@@@@@@@@@@@@@@@-     
//                 %@@@@@@@@@@@@@@@@@@@@@@@%       :%@@@@@@@@@@@@@@@@@@@@@@@@@*      
//                [email protected]@@@@@@@@@@@@@@@@@@@@@@@@=       [email protected]@@@@@@@@@@@@@@@@@@@@@@@%       
//               :@@@@@@@@@@@@@@@@@@@@@@@@@@@:      .%%%%%%@@@@@@@@@@@@@@@@@@:       
//               @@@@@@@@@@@@@@@@@@@@@@@@@@@@%             #@@@@@@@@@@@@@@@@*        
//              *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+           [email protected]@@@@@@@@@@@@@@@@.        
//             :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.         [email protected]@@@@@@@@@@@@@@@@-         
//             #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#         %@@@@@@@@@@@@@@@@+          
//            [email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+       [email protected]@@@@@@@@@@@@@@@@           
//           :@@@@@@@@@@@@@@@@@#@@@@@@@@@@@@@@@@@.      @@@@@@@@@@@@@@@@@-           
//           %@@@@@@@@@@@@@@@@+ #@@@@@@@@@@@@@@@@%     *@@@@@@@@@@@@@@@@#            
//          [email protected]@@@@@@@@@@@@@@@%  [email protected]@@@@@@@@@@@@@@@@=   [email protected]@@@@@@@@@@@@@@@@.            
//         [email protected]@@@@@@@@@@@@@@@@-   [email protected]@@@@@@@@@@@@@@@@  [email protected]@@@@@@@@@@@@@@@@-             
//         *@@@@@@@@@@@@@@@@#     @@@@@@@@@@@@@@@@@% #@@@@@@@@@@@@@@@@*              
//        [email protected]@@@@@@@@@@@@@@@@.      @@@@@@@@@@@@@@@@@#@@@@@@@@@@@@@@@@@.              
//       [email protected]@@@@@@@@@@@@@@@@:       [email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@=               
//       #@@@@@@@@@@@@@@@@*         %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%                
//      [email protected]@@@@@@@@@@@@@@@@          :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.                
//      @@@@@@@@@@@@@@@@@-           *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@=                 
//     #@@@@@@@@@@@@@@@@%             %@@@@@@@@@@@@@@@@@@@@@@@@@@@#                  
//    [email protected]@@@@@@@@@@@@@@@@@@@@@@%       [email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@:                  
//   [email protected]@@@@@@@@@@@@@@@@@@@@@@@@*       [email protected]@@@@@@@@@@@@@@@@@@@@@@@@+                   
//   *@@@@@@@@@@@@@@@@@@@@@@@@@@:       @@@@@@@@@@@@@@@@@@@@@@@@#                    
//  :@@@@@@@@@@@@@@@@@@@@@@@@@@@%       [email protected]@@@@@@@@@@@@@@@@@@@@@@.                    
// .%@@@@@@@@@@@@@@@@@@@@@@@@@@@@=       [email protected]@@@@@@@@@@@@@@@@@@@@+                     
// *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        #@@@@@@@@@@@@@@@@@@@%                      
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#       [email protected]@@@@@@@@@@@@@@@@@@-                      
// [email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@=       -%@@@@@@@@@@@@@@@%-                       
//    .............................           ... ...... ..   
                                                                                                                                                                             
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract DictatorsHeartbeat is ERC721, Ownable {
    uint256 public mintPrice;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public maxPerWallet;
    bool public isPublicMintEnabled;
    string internal baseTokenURI;
    address payable public withdrawWallet;
    mapping(address => uint256) public walletMints;

    constructor() payable ERC721('Dictators Heartbeat', 'DH') {
        mintPrice = 0.05 ether;
        totalSupply = 0;
        maxSupply = 10000;
        maxPerWallet = 20;
        isPublicMintEnabled = true;
    }

    function setIsPublicMintEnabled(bool isPublicMintEnabled_) external onlyOwner{
        isPublicMintEnabled = isPublicMintEnabled_;
    }

    function setWithdrawWallet(address payable wallet_) external onlyOwner {
        withdrawWallet = wallet_;
    }

    function setBaseTokenURI(string calldata baseTokenURI_) external onlyOwner {
        baseTokenURI = baseTokenURI_;
    }

    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        require(_exists(tokenId_), 'Token does not exist!');
        return string(abi.encodePacked(baseTokenURI, Strings.toString(tokenId_), ".json"));
    }

    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{ value: address(this).balance }('');
        require(success, 'withdraw failed');
    }

    function mint(uint256 quantity_) public payable {
        require(isPublicMintEnabled, 'minting not enabled');
        require(msg.value == quantity_ * mintPrice, 'wrong mint value');
        require(totalSupply + quantity_ <= maxSupply, 'sold out');
        require(walletMints[msg.sender] + quantity_ <= maxPerWallet, 'exceed max wallet');

        for (uint256 i = 0; i < quantity_; i++){
            uint256 newTokenId = totalSupply + 1;
            totalSupply++;
            _safeMint(msg.sender, newTokenId);
        }
    }

    function ownerMint(uint256 quantity_) external onlyOwner {
        require(totalSupply + quantity_ <= maxSupply, 'sold out');
        for (uint256 i = 0; i < quantity_; i++){
            uint256 newTokenId = totalSupply + 1;
            totalSupply++;
            _safeMint(msg.sender, newTokenId);
        }
    }

    function giveawayMint(uint256 quantity_, address receiveAddress_) external onlyOwner {
        require(totalSupply + quantity_ <= maxSupply, 'sold out');
        for (uint256 i = 0; i < quantity_; i++){
            uint256 newTokenId = totalSupply + 1;
            totalSupply++;
            _safeMint(receiveAddress_, newTokenId);
        }
    }

}