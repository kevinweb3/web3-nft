// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;
    uint256 MAX_SUPPLY = 100000; // 设置最大的铸币数量
    uint public constant price = 0.05 ether;
    bool public saleIsActive = true;

    constructor(
        address initialOwner
    ) ERC721("MyNFT", "NFT") Ownable(initialOwner) {}

    mapping(address => uint) mintAmount;

    // Set Sale state
    function setSaleState(bool _activeState) public onlyOwner {
        saleIsActive = _activeState;
    }

    function mintNFT(address to, string memory uri) public onlyOwner {
        // 判断是否超过设置的最大铸币数量
        require(_nextTokenId <= MAX_SUPPLY, "I'm sorry we reached the cap");
        // 设置每个用户只能铸币10个NFT
        require(mintAmount[msg.sender] <= 10);
        uint256 tokenId = _nextTokenId++;
        mintAmount[msg.sender]++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // 批量 Mint NFTs
    function mintNfts(
        address to,
        string memory uri,
        uint _count
    ) public payable {
        require(saleIsActive, "Sale is not currently active!");
        require(msg.value >= price * _count, "Not enough ether to purchase.");

        for (uint i = 0; i < _count; i++) {
            mintNFT(to, uri);
        }
    }

    // 给NFT定价
    function mintToken(
        address to,
        uint256 tokenId,
        string memory uri
    ) public payable virtual {
        require(msg.value >= 10, "Not enough ETH sent; check price!");

        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // Withdraw ether
    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
