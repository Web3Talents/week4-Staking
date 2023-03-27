// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const stake = await hre.ethers.getContractFactory("StakingContract");
  const deployStaking  = await stake.deploy('0x9A2C56348B0AEaCEA2AE582E6b446c9A8174868d');
  await deployStaking.deployed()
  console.log("Staking deployed at: ", deployStaking.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
