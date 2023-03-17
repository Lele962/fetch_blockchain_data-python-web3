// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";

contract DAOMember is Ownable, ERC721AQueryable {
    using ECDSA for bytes32;

    enum Status {
        // the status of ready to mint.
        Pending,
        // the status of after member minted.
        Active,
        // the status set by community for security.
        // can be active again.
        Suspended,
        // the status set by community or member reason for member quit.
        // can be active again.
        Archived
    }

    string public baseURI;

    address private signer;
    mapping(uint256 => Status) public memberStatuses;

    event SignerChanged(address operator, address from, address to);
    event BaseURIChanged(
        address operator,
        string fromBaseURI,
        string toBaseURI
    );
    event Minted(address from, address to, uint256 tokenId);
    event StatusChanged(address operator, Status fromStatus, Status toStatus);

    constructor(
        address _signer,
        string memory _baseURI
    ) ERC721A("8DAOMember", "8DM") {
        require(
            _signer != address(0),
            "The signer cannot be initialized zero."
        );
        signer = _signer;

        baseURI = _baseURI;
    }

    function _hashBytes(address from) internal pure returns (bytes32) {
        return keccak256(abi.encode(from));
    }

    function _hashAddress(address sender) internal pure returns (bytes32) {
        return keccak256(abi.encode(sender));
    }

    function _verify(
        bytes32 hash,
        bytes memory token
    ) internal view returns (bool) {
        return (_recover(hash, token) == signer);
    }

    function _recover(
        bytes32 hash,
        bytes memory token
    ) internal pure returns (address) {
        return hash.toEthSignedMessageHash().recover(token);
    }

    function setSigner(address _signer) external onlyOwner {
        emit SignerChanged(_msgSender(), signer, _signer);
        signer = _signer;
    }

    function getSigner() external view onlyOwner returns (address) {
        return signer;
    }

    function updateBaseURI(string calldata _newBaseURI) external onlyOwner {
        emit BaseURIChanged(msg.sender, baseURI, _newBaseURI);
        baseURI = _newBaseURI;
    }

    function mint(bytes calldata signature) external {
        require(balanceOf(_msgSender()) == 0, "The member has already minted.");

        require(
            _verify(_hashBytes(_msgSender()), signature),
            "Invalid signature."
        );

        uint256 tokenId = _nextTokenId();
        _safeMint(_msgSender(), 1);
        memberStatuses[tokenId] = Status.Active;

        emit Minted(_msgSender(), _msgSender(), tokenId);
    }

    function mintAndAirdrop(address[] calldata members) external onlyOwner {
        for (uint256 i = 0; i < members.length; i++) {
            address member = members[i];
            //            require(balanceOf(member) == 0, "The member has already minted.");
            if (balanceOf(member) == 0) {
                uint256 tokenId = _nextTokenId();
                _safeMint(member, 1);
                memberStatuses[tokenId] = Status.Active;

                emit Minted(_msgSender(), member, tokenId);
            }
        }
    }

    function activate(uint256 tokenId) external onlyOwner {
        require(
            memberStatuses[tokenId] == Status.Suspended ||
                memberStatuses[tokenId] == Status.Archived,
            "The member is not suspended or archived now."
        );

        memberStatuses[tokenId] = Status.Active;
        emit StatusChanged(_msgSender(), Status.Pending, Status.Active);
    }

    function suspend(uint256 tokenId) external onlyOwner {
        require(
            memberStatuses[tokenId] == Status.Active,
            "The member is not activating now."
        );

        memberStatuses[tokenId] = Status.Suspended;
        emit StatusChanged(_msgSender(), Status.Active, Status.Suspended);
    }

    function archive(uint256 tokenId) external {
        if (_msgSender() == owner()) {
            _archive(_msgSender(), tokenId);
        } else {
            require(
                ownerOf(tokenId) == _msgSender(),
                "Only owner can archive."
            );
            _archive(_msgSender(), tokenId);
        }
    }

    function _archive(address from, uint256 tokenId) private {
        require(
            memberStatuses[tokenId] == Status.Active,
            "The member is not activating now."
        );

        memberStatuses[tokenId] = Status.Archived;
        emit StatusChanged(from, Status.Active, Status.Archived);
    }

    function approve(
        address,
        uint256
    ) public payable override(ERC721A, IERC721A) {
        require(false, "Cannot approve.");
    }

    function setApprovalForAll(
        address,
        bool
    ) public pure override(ERC721A, IERC721A) {
        require(false, "Cannot setApprovalForAll.");
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view override(ERC721A, IERC721A) returns (bool) {
        if (_msgSender() == super.owner()) {
            return true;
        }
        return super.isApprovedForAll(owner, operator);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override(ERC721A, IERC721A) onlyOwner {
        safeTransferFrom(from, to, tokenId, bytes(""));
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public payable override(ERC721A, IERC721A) onlyOwner {
        _transferToken(from, to, tokenId, _data);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override(ERC721A, IERC721A) onlyOwner {
        _transferToken(from, to, tokenId, bytes(""));
    }

    function _transferToken(
        address from,
        address to,
        uint256 tokenId,
        bytes memory
    ) private {
        require(ownerOf(tokenId) == from, "`from` address has no token.");
        require(balanceOf(to) == 0, "`to` address already has token.");
        require(
            memberStatuses[tokenId] == Status.Suspended,
            "The Active or archived token cannot be transfer."
        );

        super.transferFrom(from, to, tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(tokenId)) {
            return "";
        }
        address owner = this.ownerOf(tokenId);
        return string(abi.encodePacked(baseURI, Strings.toHexString(owner)));
    }

    function tokenIdOfOwner(address owner) public view returns (uint256) {
        require(balanceOf(owner) > 0, "`from` address has no token.");
        uint256[] memory tokens = this.tokensOfOwner(owner);
        return tokens[0];
    }

    function balanceOf8DAOTokens(
        address[] calldata members,
        address token
    ) external view returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](members.length);
        for (uint256 i = 0; i < members.length; i++) {
            uint256 amount = IERC20(token).balanceOf(members[i]);
            amounts[i] = amount;
        }
        return amounts;
    }
}