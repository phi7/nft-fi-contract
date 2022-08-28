// run.js
const main = async () => {
    const [owner,randomPerson1, randomPerson2] = await hre.ethers.getSigners();
    console.log("Deploying contracts with account: ", owner.address);

    //nftを発行するコントラクトのデプロイ
    const nftMintFactory = await hre.ethers.getContractFactory("NFTMint");
    const nftMintContract = await nftMintFactory.deploy();
    const nftMint = await nftMintContract.deployed();
    console.log("NFTMint address: ", nftMint.address);


    //nftを発行する
    let nftMintTxn = await nftMintContract.makeAnEpicNFT();
    // Minting が仮想マイナーにより、承認されるのを待つ。
    await nftMintTxn.wait();
    console.log("owner",(await nftMintContract.ownerOf(0)));

    //nft-fiのコントラクトのデプロイ
    const nftFiContractFactory = await hre.ethers.getContractFactory("Nftfi");
    const nftFiContract = await nftFiContractFactory.deploy(nftMintContract.address);
    const nftFi = await nftFiContract.deployed();
    console.log("NFTFi address: ", nftFi.address);

    //collateralizeする
    let collateralizeTxn = await nftFiContract.collateralize(nftMintContract.address,0);
    await collateralizeTxn.wait();
    // console.log(collateralizeTxn);
    let collateralizedNFTs = await nftFiContract.getCollateralizedNFTs();
    console.log(collateralizedNFTs);

    // let makeBidTxn = await nftFiContract.makeBid(0, 200);
    // await makeBidTxn.wait();
    // let collateralizedNFTs2 = await nftFiContract.getCollateralizedNFTs();
    // console.log(collateralizedNFTs2);

  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();