// 铸币脚本文件，或者直接在Remix部署脚本和执行合约铸币函数
require('dotenv').config();
const ethers = require('ethers');
const contract = require("../artifacts/contracts/MyNFT.sol/MyNFT.json");
const contractInfo = require("../contractInfo/MyNFT.json");

// Get Alchemy App URL
const API_KEY = process.env.REACT_APP_ALCHEMY_Sepolia_API_KEY;

// Define an Alchemy Provider
const provider = new ethers.AlchemyProvider('sepolia', API_KEY);
// Create a signer
const privateKey = process.env.REACT_APP_PRIVATE_KEY;
const signer = new ethers.Wallet(privateKey, provider)

// Get contract ABI and address
const abi = contract.abi;
const contractAddress = contractInfo.contractAddress;

// Create a contract instance
const myNftContract = new ethers.Contract(contractAddress, abi, signer)

// Get the NFT Metadata IPFS URL
const tokenUri = "https://gateway.pinata.cloud/ipfs/QmU751kqdPRSDxCXrgRk3hoJmtcb8ZtJoWgVMJDMoCd6NS"

// Call mintNFT function
const mintNFT = async () => {
    let nftTxn = await myNftContract.mintNFT(signer.address, tokenUri)
    await nftTxn.wait()
    console.log(`NFT Minted! Check it out at: https://sepolia.etherscan.io/tx/${nftTxn.hash}`)
}

mintNFT()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });