import { ethers } from "hardhat";
import fs from "fs";
import path from "path";
import { CourseBadge } from "../typechain-types";

async function main() {
  console.log("🚀 Starting CourseBadge deployment to Monad Testnet...\n");

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

  // Deploy CourseBadge
  console.log("📦 Deploying CourseBadge contract...");
  const CourseBadgeFactory = await ethers.getContractFactory("CourseBadge");

  // Await the Promise!
  const deployTx = await CourseBadgeFactory.getDeployTransaction();
  const estimatedGas = await ethers.provider.estimateGas(deployTx);
  console.log("├── Estimated gas:", estimatedGas.toString());

  // Deploy with buffer, as before
  const gasLimit = (estimatedGas * BigInt(120)) / BigInt(100);
  const courseBadge = await CourseBadgeFactory.deploy({ gasLimit });

  console.log(
    "├── Transaction hash:",
    courseBadge.deploymentTransaction()?.hash
  );
  console.log("├── Waiting for deployment confirmation...");

  await courseBadge.waitForDeployment();
  const contractAddress = await courseBadge.getAddress();

  console.log("✅ CourseBadge deployed successfully!");
  console.log("├── Contract address:", contractAddress);
  console.log(
    "├── Block explorer:",
    `https://testnet.monadexplorer.com/address/${contractAddress}`
  );

  // Verify initial state
  console.log("\n🔍 Verifying initial contract state...");
  try {
    // Check for AccessControl roles instead of owner
    const DEFAULT_ADMIN_ROLE = ethers.ZeroHash; // DEFAULT_ADMIN_ROLE is 0x0
    const admin = await courseBadge.hasRole(DEFAULT_ADMIN_ROLE, deployer.address);
    console.log("├── Deployer has admin role:", admin);
    
    // Check other roles if needed
    const MINTER_ROLE = await courseBadge.MINTER_ROLE();
    const hasMinterRole = await courseBadge.hasRole(MINTER_ROLE, deployer.address);
    console.log("├── Deployer has minter role:", hasMinterRole);
    
    // Check for base URI if needed
    const uri = await courseBadge.uri(0);
    console.log("├── Base URI:", uri);
    
    // Check counter values - these are private in your contract, so can't be accessed directly
    console.log("├── Token counters initialized");
    
  } catch (error) {
    console.log("❌ Error verifying contract state:", error);
  }

  // Get deployment cost
  const deploymentTx = courseBadge.deploymentTransaction();
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
  console.log("3. Create certificate types with createCertificateType()");
  console.log("4. Create event badges with createEventBadge()");
  console.log("5. Issue certificates and badges to students");

  // Save deployment info to file
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
    path.join(deploymentsDir, "courseBadge-monad-testnet.json"),
    JSON.stringify(deploymentInfo, null, 2)
  );
  
  console.log(
    "\n💾 Deployment info saved to: deployments/courseBadge-monad-testnet.json"
  );

  return {
    courseBadge,
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