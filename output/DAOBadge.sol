// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract DAOBadge is Ownable, ERC1155Supply {
    using Strings for uint256;
    using Counters for Counters.Counter;

    string public baseURI;
    Counters.Counter private _tokenIds;

    mapping(uint256 => string) private _tokenIdTypes;
    mapping(string => uint256) private _typeTokens;
    string[] private _types;

    struct MemberTypeAmounts {
        string[] types;
        uint256[] amounts;
    }

    event AddType(address operator, string newType);
    event BaseURIChanged(
        address operator,
        string fromBaseURI,
        string toBaseURI
    );

    constructor(string memory _baseURI) ERC1155(_baseURI) {
        addType("Governance");
        addType("Investment");
        baseURI = _baseURI;
    }

    function updateBaseURI(string calldata _newBaseURI) external onlyOwner {
        emit BaseURIChanged(msg.sender, baseURI, _newBaseURI);
        baseURI = _newBaseURI;
    }

    function addType(string memory badgeType) public onlyOwner {
        require(_typeTokens[badgeType] == 0, "the type is exist");
        if (_typeTokens[badgeType] == 0) {
            _tokenIds.increment();
            uint256 tokenId = _tokenIds.current();
            _tokenIdTypes[tokenId] = badgeType;
            _typeTokens[badgeType] = tokenId;
            _types.push(badgeType);

            emit AddType(msg.sender, badgeType);
        }
    }

    function getAllTypes() public view returns (string[] memory) {
        return _types;
    }

    function getTokenId(
        string calldata badgeType
    ) public view returns (uint256) {
        return _typeTokens[badgeType];
    }

    function balanceOfType(
        string memory badgeType,
        address[] calldata members
    ) external view returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](members.length);
        for (uint256 i = 0; i < members.length; i++) {
            uint256 amount = balanceOf(members[i], _typeTokens[badgeType]);
            amounts[i] = amount;
        }
        return amounts;
    }

    function balanceOfAllTypes(
        address[] calldata members
    ) external view returns (MemberTypeAmounts[] memory) {
        MemberTypeAmounts[] memory result = new MemberTypeAmounts[](
            members.length
        );

        uint256 typesCount = _types.length;

        for (uint256 i = 0; i < members.length; i++) {
            MemberTypeAmounts memory container = result[i];
            container.types = new string[](typesCount);
            container.amounts = new uint256[](typesCount);

            for (uint256 j = 0; j < typesCount; j++) {
                string memory badgeType = _types[j];
                container.types[j] = badgeType;
                container.amounts[j] = balanceOf(
                    members[i],
                    _typeTokens[badgeType]
                );
            }
        }

        return result;
    }

    function mintAndAirdrop(
        string calldata badgeType,
        address[] calldata members,
        uint256[] calldata amounts
    ) external onlyOwner {
        uint256 tokenId = _typeTokens[badgeType];
        require(tokenId != 0, "the type is not exist");
        require(
            members.length == amounts.length,
            "members and amounts length not equal"
        );

        for (uint256 i = 0; i < members.length; i++) {
            _mint(members[i], tokenId, amounts[i], "");
        }
    }

    function burn(
        address member,
        string calldata badgeType,
        uint256 amount
    ) external onlyOwner {
        uint256 tokenId = _typeTokens[badgeType];
        require(tokenId != 0, "the type is not exist");
        super._burn(member, tokenId, amount);
    }

    function setApprovalForAll(address, bool) public virtual override(ERC1155) {
        revert("Cannot setApprovalForAll.");
    }

    function isApprovedForAll(
        address,
        address
    ) public view virtual override(ERC1155) returns (bool) {
        return false;
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override(ERC1155) {
        revert("Cannot safeTransferFrom.");
    }

    function safeBatchTransferFrom(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override(ERC1155) {
        revert("Cannot safeBatchTransferFrom.");
    }

    function uri(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        return string(abi.encodePacked(baseURI, _tokenIdTypes[tokenId]));
    }
}