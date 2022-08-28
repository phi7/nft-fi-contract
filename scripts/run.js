// run.js
const main = async () => {
    const [owner,randomPerson1, randomPerson2] = await hre.ethers.getSigners();
    
    const nftMintFactory = await hre.ethers.getContractFactory("NFTMint");
    const nftMintContract = await nftMintFactory.deploy();
    const nftMint = await nftMintContract.deployed();
    console.log("NFTMint address: ", nftMint.address);


    const nftFiContractFactory = await hre.ethers.getContractFactory("Nftfi");
    const nftFiContract = await nftFiContractFactory.deploy();
    const nftFi = await nftFiContract.deployed();
  
    console.log("NFTFi address: ", nftFi.address);
    console.log("Deploying contracts with account: ", owner.address);

    let nftMintTxn = await nftMintContract.makeAnEpicNFT();
    // Minting が仮想マイナーにより、承認されるのを待つ。
    await nftMintTxn.wait();

    let collateralizeTxn = await nftFiContract.collateralize(nftMintContract.address,0);
    await collateralizeTxn.wait();
    // console.log(collateralizeTxn);
    let collateralizedNFTs = await nftFiContract.getCollateralizedNFTs();
    console.log(collateralizedNFTs);

    // let makeBidTxn = await nftFiContract.makeBid(0, 200);
    // await makeBidTxn.wait();
    // let collateralizedNFTs2 = await nftFiContract.getCollateralizedNFTs();
    // console.log(collateralizedNFTs2);


    // nftFiContract.collateralize()
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