// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";
import "./nft_mint.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface INftMint {
    function transferFrom(
        address _from,
        address _to,
        uint256 tokenId
    ) external;

    // function approve(address to, uint256 tokenId) external;

    // function safetransferFrom(
    //     address _from,
    //     address _to,
    //     uint256 tokenId
    // ) external;


}

interface IGyen {
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external;

    // function approve(address spender, uint256 amount) external;

    // function safetransferFrom(
    //     address _from,
    //     address _to,
    //     uint256 tokenId
    // ) external;
}

contract Nftfi {
    // NFT トークンの名前とそのシンボルを渡します。
    // constructor() ERC721("SquareNFT", "SQUARE") {
    //     console.log("This is my NFT contract.");
    // }
    INftMint nftMint;
    IGyen gyen;

    using SafeMath for uint256;

    constructor(){
        // address nftMintAdrr = _nftMintAdrr;
        nftMint = INftMint(0x842BDfd7da2d603b176f0E41B58a6f2D785aFBcA);
        gyen = IGyen(0x2d74278AF15427f2b8216Ad29C947e44B86D3934);
    }

    // 融資金額の５％は投資者へ返還
    uint256 profitToInvester = 5;
    // 融資金額の５％はプラットフォームへ返還
    uint256 profitToPlatform = 5;

    //担保に出されたNFTの情報
    struct CollateralizedNFTInfo {
        //countIndexはリストの何番目にあるかを示す
        uint256 countIndex;
        address collateralizer;
        address nftContractAddress;
        uint256 tokenId;
        uint256 timestamp;
        uint256 auctionDuration;
        uint256 loanStartTime;
        uint256 loanDuration;
        address invester;
        bool isBidding;
        uint256 biggestBidPrice;
        bool isCollateralizing;
    }

    //担保に出されたNFTの情報の一覧
    CollateralizedNFTInfo[] collateralizedNFTs;
    // uint counter = 0;
    
    // mapping(uint => CollateralizedNFTInfo)CollateralizeInfo;

    //担保者と担保に出されたNFTの情報の紐付け
    // mapping(address => uint256[]) collateralizerNFTList;

    //NFTを担保に出す関数
    function collateralize(address _nftContractAddress, uint256 _tokenId)
        external
        payable
    {
        uint256 timestamp = block.timestamp;
        // uint256 initialPrice = 100;
        uint256 collateralizerNFTListLength = collateralizedNFTs.length;
        CollateralizedNFTInfo
            memory newCollateralizedNFT = CollateralizedNFTInfo(
                collateralizerNFTListLength,
                msg.sender,
                _nftContractAddress,
                _tokenId,
                timestamp,
                //オークションの期間は１週間
                1 weeks,
                //運用開始時間は最初は０
                0,
                //ローンの期間は１週間
                1 weeks,
                address(0),
                //isBidding
                false,
                //最初の最大の価格はinitialPriceと一致
                100,
                true
            );
        // collateralizerNFTList[msg.sender].push(newCollateralizedNFT);
        collateralizedNFTs.push(newCollateralizedNFT);
        // console.log();
        // console.log("collateralize!");
        // emit DebugLogEvent("Print Log!");
        // return collateralizedNFTs;
        // transferFrom();
        console.log("caller %s",msg.sender);
        // nftMint.approve(address(this), _tokenId);
        nftMint.transferFrom(msg.sender, address(this), _tokenId);
        // nftMint.safetransferFrom(msg.sender, address(this), _tokenId);

        // CollateralizeInfo[counter] = CollateralizedNFTInfo(

        // );
        // counter++;

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
    function makeBid(uint256 countIndex, uint256 price) external payable {
        require(collateralizedNFTs[countIndex].biggestBidPrice < price);
        collateralizedNFTs[countIndex].invester = msg.sender;
        collateralizedNFTs[countIndex].biggestBidPrice = price;
        collateralizedNFTs[countIndex].isBidding = true;
        // gyen.approve(address(this), price);
        gyen.transferFrom(msg.sender, address(this), price);
    }

    //NFTホルダーが落札を決定する関数
    function accept(uint256 countIndex) external payable {
        require(collateralizedNFTs[countIndex].collateralizer == msg.sender, "not owner of the token");
        //最低一人は入札しているかどうか
        require(collateralizedNFTs[countIndex].isBidding,"not yet bidding");
        //ローンの開始時間を記録
        collateralizedNFTs[countIndex].loanStartTime = block.timestamp;
        gyen.transferFrom(address(this),collateralizedNFTs[countIndex].collateralizer,collateralizedNFTs[countIndex].biggestBidPrice);
    }

    //返済するための関数
    //ローン期間が過ぎてなければNFTを戻す
    function payback(uint256 countIndex) external payable{
        //呼び出した人がNFTを担保に出した人か確認
        require(collateralizedNFTs[countIndex].collateralizer == msg.sender, "not owner of the token");
        //ローンの期間がすぎていないか確認
        require(block.timestamp <= collateralizedNFTs[countIndex].loanStartTime.add(collateralizedNFTs[countIndex].loanDuration) );
        nftMint.transferFrom(address(this), msg.sender, collateralizedNFTs[countIndex].tokenId);
        //ここでaproveしてから利息付きのGyenをNFTホルダーから投資家にtransferfromしてもよい
    }

    //ローン期間がすぎたけど返済されなかったので清算する関数
    function liquidate(uint256 countIndex) external payable{
        //ローン期間がすぎたかをチェック
        require(block.timestamp < collateralizedNFTs[countIndex].loanStartTime.add(collateralizedNFTs[countIndex].loanDuration),"yet loan continues..." );
        nftMint.transferFrom(address(this), collateralizedNFTs[countIndex].invester, collateralizedNFTs[countIndex].tokenId);
    }

    //入札がなく、オークション期間が終わった場合
    function withdraw(uint256 countIndex) external payable{
        //呼び出した人がNFTを担保に出した人か確認
        require(collateralizedNFTs[countIndex].collateralizer == msg.sender, "not owner of the token");
        //入札が入っていないか
        require(!collateralizedNFTs[countIndex].isBidding,"Already Bidded...");
        //オークション期間が過ぎたか
        require(collateralizedNFTs[countIndex].timestamp.add(collateralizedNFTs[countIndex].auctionDuration) < block.timestamp, "Still auction time");
        nftMint.transferFrom(address(this), msg.sender, collateralizedNFTs[countIndex].tokenId);


    }
}
