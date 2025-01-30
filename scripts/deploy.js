const { ethers } = require("hardhat");
const { parseEther } = require("ethers");

async function main() {
  // Get the contract factory
  const contract = await ethers.getContractFactory("HealthcareManagementSystem");

  // Deploy the contract with constructor argument
  const deployedContract = await contract.deploy();
  await deployedContract.waitForDeployment();

  console.log("HealthcareManagementSystem Contract deployed to", deployedContract.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
