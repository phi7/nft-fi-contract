// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  //NFTをミントするスマートコントラクトのデプロイ
  // const nftMintFactory = await hre.ethers.getContractFactory("NFTMint");
  // const nftMintContract = await nftMintFactory.deploy();
  // const nftMint = await nftMintContract.deployed();
  // console.log("NFTMint address: ", nftMint.address);
  
  //nft-fiのコントラクトのデプロイ
  const nftFiContractFactory = await hre.ethers.getContractFactory("Nftfi");
  const nftFiContract = await nftFiContractFactory.deploy();
  const nftFi = await nftFiContract.deployed();
  console.log("NFTFi address: ", nftFi.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

runMain();
