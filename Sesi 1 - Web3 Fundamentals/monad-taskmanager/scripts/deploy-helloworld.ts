import { ethers } from "hardhat";
import { HelloWorld } from "../typechain-types";

async function main() {
  console.log("🚀 Starting HelloWorld deployment...\n");

  // Get deployer wallet
  const [deployer] = await ethers.getSigners();
  console.log("📋 Deployment Details:");
  console.log("├── Deployer address:", deployer.address);

  // Check balance
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("├── Deployer balance:", ethers.formatEther(balance), "ETH");

  if (balance < ethers.parseEther("0.005")) {
    console.log("⚠️  Warning: Low balance. Make sure you have enough ETH.");
  }

  const network = await ethers.provider.getNetwork();
  console.log("├── Network:", network.name);
  console.log("├── Chain ID:", network.chainId.toString(), "\n");

  // Deploy contract
  const HelloWorldFactory = await ethers.getContractFactory("HelloWorld");

  // Estimate gas
  const deployTx = await HelloWorldFactory.getDeployTransaction();
  const estimatedGas = await ethers.provider.estimateGas(deployTx);
  const gasLimit = (estimatedGas * BigInt(120)) / BigInt(100);

  console.log("📦 Deploying HelloWorld contract...");
  const helloWorld: HelloWorld = await HelloWorldFactory.deploy({ gasLimit });

  console.log("├── Tx hash:", helloWorld.deploymentTransaction()?.hash);
  await helloWorld.waitForDeployment();
  const address = await helloWorld.getAddress();

  console.log("✅ HelloWorld deployed!");
  console.log("├── Contract address:", address);
  console.log("├── Explorer (if available): https://example-explorer.com/address/" + address);

  // Test initial value
  const say = await helloWorld.getSay();
  console.log("🔍 Initial value of `say`:", say);

  // Get deployment cost
  const receipt = await helloWorld.deploymentTransaction()?.wait();
  if (receipt) {
    const cost = receipt.gasUsed * receipt.gasPrice;
    console.log("\n💰 Deployment Cost:");
    console.log("├── Gas used:", receipt.gasUsed.toString());
    console.log("├── Gas price:", ethers.formatUnits(receipt.gasPrice, "gwei"), "gwei");
    console.log("└── Total cost:", ethers.formatEther(cost), "ETH");
  }

  // Save to file
  const fs = require("fs");
  const path = require("path");
  const deploymentsDir = path.join(__dirname, "..", "deployments");

  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir);
  }

  fs.writeFileSync(
    path.join(deploymentsDir, "helloworld-deployment.json"),
    JSON.stringify(
      {
        contractAddress: address,
        deployer: deployer.address,
        network: network.name,
        chainId: network.chainId.toString(),
        timestamp: new Date().toISOString(),
        txHash: receipt?.hash,
      },
      null,
      2
    )
  );

  console.log("\n💾 Deployment info saved to: deployments/helloworld-deployment.json");
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("\n❌ Deployment failed:", err);
    process.exit(1);
  });
