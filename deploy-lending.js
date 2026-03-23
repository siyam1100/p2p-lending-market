const hre = require("hardhat");

async function main() {
  const USDC_ADDRESS = "0x..."; // Mock USDC
  
  const Lending = await hre.ethers.getContractFactory("LendingMarket");
  const lending = await Lending.deploy(USDC_ADDRESS);
  await lending.waitForDeployment();

  console.log("Lending Market deployed to:", await lending.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
