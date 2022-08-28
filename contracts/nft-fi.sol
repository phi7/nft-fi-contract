// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";
import "./nft_mint.sol";

interface INftMint {
    function transferFrom(
        address _from,
        address _to,
        uint256 tokenId
    ) external;
}

contract Nftfi {
    // NFT トークンの名前とそのシンボルを渡します。
    // constructor() ERC721("SquareNFT", "SQUARE") {
    //     console.log("This is my NFT contract.");
    // }
    address private nftMintAdrr = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    INftMint nftMint = INftMint(nftMintAdrr);

    //担保に出されたNFTの情報
    struct CollateralizedNFTInfo {
        //countIndexはリストの何番目にあるか
        uint256 countIndex;
        address collateralizer;
        address nftContractAddress;
        uint256 tokenId;
        uint256 timestamp;
        address invester;
        uint256 price;
        bool isCollateralizing;
    }

    //担保に出されたNFTの情報の一覧
    CollateralizedNFTInfo[] collateralizedNFTs;

    //担保者と担保に出されたNFTの情報の紐付け
    // mapping(address => uint256[]) collateralizerNFTList;

    //NFTを担保に出す関数
    function collateralize(address _nftContractAddress, uint256 _tokenId)
        external
        payable
    {
        uint256 timestamp = block.timestamp;
        uint256 initialPrice = 100;
        uint256 collateralizerNFTListLength = collateralizedNFTs.length;
        CollateralizedNFTInfo
            memory newCollateralizedNFT = CollateralizedNFTInfo(
                collateralizerNFTListLength,
                msg.sender,
                _nftContractAddress,
                _tokenId,
                timestamp,
                address(0),
                initialPrice,
                true
            );
        // collateralizerNFTList[msg.sender].push(newCollateralizedNFT);
        collateralizedNFTs.push(newCollateralizedNFT);
        // console.log();
        // console.log("collateralize!");
        // emit DebugLogEvent("Print Log!");
        // return collateralizedNFTs;
        // transferFrom();
        nftMint.transferFrom(msg.sender, address(this), _tokenId);
        console.log("collateralize!");
    }

    //担保に出されているNFTの情報をすべて取得する関数
    function getCollateralizedNFTs()
        external
        view
        returns (CollateralizedNFTInfo[] memory)
    {
        return collateralizedNFTs;
    }

    //投資家がNFTを入札する関数
    function makeBid(uint256 countIndex, uint256 price) external {
        require(collateralizedNFTs[countIndex].price < price);
        collateralizedNFTs[countIndex].invester = msg.sender;
        collateralizedNFTs[countIndex].price = price;
        // trnasfer
    }
}
