// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Errors
error BasicNft__TransferFailed();
error BasicNft__AlreadyInitialized();
error BasicNft__MintFailed();

contract BasicNft is ERC721URIStorage, Ownable {
    // NFT Variables
    string internal i_collectionName;
    string internal i_collectionSymbol;
    uint256 private immutable i_mintFee;
    string internal s_tokenRootCid;
    bool private s_initialized;

    uint256 private _tokenIdCounter = 1;
    uint256 public MAX_SUPPLY = 1600;
    uint256 public MAX_PER_WALLLET;
    uint256 public MAX_PER_MINT;
    address private SPLIT_ADDRESS;
    uint8 private SPLIT_RATIO;
    address payable public creator;

    constructor(
        string memory collectionName,
        string memory collectionSymbol,
        uint256 mintFee,
        uint256 maxPerWallet,
        uint256 maxPerMint,
        address splitAddress,
        uint8 splitRatio,
        address contractCreator,
        string memory tokenRootCid
    ) ERC721(collectionName, collectionSymbol) {
        i_collectionName = collectionName;
        i_collectionSymbol = collectionSymbol;
        i_mintFee = mintFee;
        MAX_PER_WALLLET = maxPerWallet;
        MAX_PER_MINT = maxPerMint;
        SPLIT_ADDRESS = splitAddress;
        SPLIT_RATIO = splitRatio;
        creator = payable(contractCreator);
        _initializeContract(tokenRootCid);
    }

    function safeMint(address to, uint256 mintAmount) public payable {
        require(_tokenIdCounter <= MAX_SUPPLY, "I'm sorry we reached the cap");
        // require(balanceOf(msg.sender) <= MAX_PER_WALLLET, "Max Mint per wallet reached");
        require(mintAmount <= MAX_PER_MINT, "Max Mint per time reached");

        for (uint256 i = 1; i < mintAmount + 1; i++) {
            _safeMint(to, _tokenIdCounter);
            string memory tokenUri = uri(s_tokenRootCid, _tokenIdCounter);
            _setTokenURI(_tokenIdCounter, tokenUri);
            _tokenIdCounter++;
        }
        uint256 amount = msg.value;
        uint256 splitAmount;
        amount = ((100 - SPLIT_RATIO) / 100) * msg.value;
        splitAmount = msg.value - amount;
        creator.transfer(amount);
    }

    function splitMintFee(address receiverAddress, uint256 splitFee) private {
        (bool success, ) = payable(receiverAddress).call{value: splitFee}("");
        if (!success) {
            revert BasicNft__TransferFailed();
        }
    }

    function _initializeContract(string memory tokenRootCid) private {
        if (s_initialized) {
            revert BasicNft__AlreadyInitialized();
        }
        s_tokenRootCid = tokenRootCid;
        // MAX_SUPPLY = tokenUris.length;
        s_initialized = true;
    }

    function uri(string memory rootCid, uint256 id) public pure returns (string memory) {
        string memory idString = Strings.toString(id);
        return
            string(abi.encodePacked("https://ipfs.io/ipfs/", rootCid, "/%23", idString, ".json"));
    }

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    function getInitialized() public view returns (bool) {
        return s_initialized;
    }

    function totalSupply() public view returns (uint256) {
        return MAX_SUPPLY;
    }

    function maxWallet() public view returns (uint256) {
        return MAX_PER_WALLLET;
    }

    function maxMint() public view returns (uint256) {
        return MAX_PER_MINT;
    }
}
