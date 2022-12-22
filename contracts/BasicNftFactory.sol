// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./BasicNft.sol";

contract BasicNftFactory {
    BasicNft[] public basicNftArrays;

    struct Collection {
        string name;
        string symbol;
        string tokenRootCid;
        uint256 mintFee;
        uint256 maxPerWallet;
        uint256 maxPerMint;
        address splitAddress;
        uint8 splitRatio;
        address creator;
        uint256 collectionIndex;
        address collectionAddress;
    }

    Collection[] public collections;
    uint256 private collectionIndex;

    constructor() {}

    function createNft(
        string memory collectionName,
        string memory collectionSymbol,
        uint256 mintFee,
        uint256 maxPerWallet,
        uint256 maxPerMint,
        address splitAddress,
        uint8 splitRatio,
        string memory tokenRootCid
    ) public returns (address) {
        address contractCreator = msg.sender;
        BasicNft basicNft = new BasicNft(
            collectionName,
            collectionSymbol,
            mintFee,
            maxPerWallet,
            maxPerMint,
            splitAddress,
            splitRatio,
            contractCreator,
            tokenRootCid
        );
        address collectionAddress = address(basicNft);
        basicNftArrays.push(basicNft);
        collectionIndex = collectionIndex + 1;
        Collection memory collection = Collection(
            collectionName,
            collectionSymbol,
            tokenRootCid,
            mintFee,
            maxPerWallet,
            maxPerMint,
            splitAddress,
            splitRatio,
            msg.sender,
            collectionIndex,
            collectionAddress
        );
        collections.push(collection);
        return collectionAddress;
    }

    function getContracts() public view returns (Collection[] memory) {
        return collections;
    }

    function mintNft(uint256 contractIndex, uint256 mintAmount) public payable {
        BasicNft basicNft = basicNftArrays[contractIndex];
        basicNft.safeMint(msg.sender, mintAmount);
    }
}
