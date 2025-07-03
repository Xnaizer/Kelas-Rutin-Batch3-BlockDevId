import { ethers } from "hardhat";
import { StudentID } from "../typechain-types";

async function main() {
  console.log("🚀 Starting StudentID deployment to Monad Testnet...\n");

  // Get deployer account
  const [deployer] = await ethers.getSigners();
  console.log("📋 Deployment Details:");
  console.log("├── Deployer address:", deployer.address);

  // Check balance
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("├── Deployer balance:", ethers.formatEther(balance), "MON");

  if (balance < ethers.parseEther("0.01")) {
    console.log(
      "⚠️  Warning: Low balance. Make sure you have enough MON for deployment."
    );
  }

  // Get network info
  const network = await ethers.provider.getNetwork();
  console.log("├── Network:", network.name);
  console.log("├── Chain ID:", network.chainId.toString());
  console.log("└── RPC URL:", "https://testnet-rpc.monad.xyz/\n");

  // Deploy StudentID
  console.log("📦 Deploying StudentID contract...");
  const StudentIDFactory = await ethers.getContractFactory("StudentID");

  // Await the Promise!
  const deployTx = await StudentIDFactory.getDeployTransaction();
  const estimatedGas = await ethers.provider.estimateGas(deployTx);
  console.log("├── Estimated gas:", estimatedGas.toString());

  // Deploy with buffer, as before
  const gasLimit = (estimatedGas * BigInt(120)) / BigInt(100);
  const studentid = await StudentIDFactory.deploy({ gasLimit });

  console.log(
    "├── Transaction hash:",
    studentid.deploymentTransaction()?.hash
  );
  console.log("├── Waiting for deployment confirmation...");

  await studentid.waitForDeployment();
  const contractAddress = await studentid.getAddress();

  console.log("✅ StudentID deployed successfully!");
  console.log("├── Contract address:", contractAddress);
  console.log(
    "├── Block explorer:",
    `https://testnet.monadexplorer.com/address/${contractAddress}`
  );

  // Verify initial state
  console.log("\n🔍 Verifying initial contract state...");
  try {
    const owner = await studentid.owner();
    console.log("├── Owner:", owner);
    // Check initial token counter / totalSupply if needed
    // const nextTokenId = await studentid.callStatic._nextTokenId(); // if declared public
    // console.log("├── Next token ID:", nextTokenId.toString());
  } catch (error) {
    console.log("❌ Error verifying contract state:", error);
  }

  // Get deployment cost
  const deploymentTx = studentid.deploymentTransaction();
  if (deploymentTx) {
    const receipt = await deploymentTx.wait();
    if (receipt) {
      const cost = receipt.gasUsed * receipt.gasPrice;
      console.log("\n💰 Deployment Cost:");
      console.log("├── Gas used:", receipt.gasUsed.toString());
      console.log(
        "├── Gas price:",
        ethers.formatUnits(receipt.gasPrice, "gwei"),
        "gwei"
      );
      console.log("└── Total cost:", ethers.formatEther(cost), "MON");
    }
  }

  // Provide next steps
  console.log("\n📋 Next Steps:");
  console.log("1. Save the contract address for future interactions");
  console.log("2. Verify the contract on block explorer (optional)");
  console.log("3. Test contract functions using Hardhat console or frontend");
  console.log("4. Add the contract to your MetaMask for easy interaction");

  // Save deployment info to file
  const fs = require("fs");
  const path = require("path");
  const deploymentsDir = path.join(__dirname, "..", "deployments");
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir);
  }
  const deploymentInfo = {
    contractAddress,
    deployerAddress: deployer.address,
    network: network.name,
    chainId: network.chainId.toString(),
    blockExplorer: `https://testnet.monadexplorer.com/address/${contractAddress}`,
    timestamp: new Date().toISOString(),
    txHash: deploymentTx?.hash,
  };
  fs.writeFileSync(
    path.join(deploymentsDir, "studentid-monad-testnet.json"),
    JSON.stringify(deploymentInfo, null, 2)
  );
  console.log(
    "\n💾 Deployment info saved to: deployments/studentid-monad-testnet.json"
  );

  return {
    studentid,
    contractAddress,
    deploymentInfo,
  };
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n❌ Deployment failed:");
    console.error(error);
    process.exit(1);
  });