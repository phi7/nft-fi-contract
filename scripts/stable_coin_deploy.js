main3()

async function main3 () {
  try {
    const GMOCoin = await ethers.getContractFactory("Gyen")
    const gmoCoin = await GMOCoin.deploy()

    console.info(`Token address: ${gmoCoin.address}`)
  } catch (err) {
    console.error(err)
  }
}