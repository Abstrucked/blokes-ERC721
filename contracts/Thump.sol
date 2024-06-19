// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
/// @dev counters is obsolete in OpenZeppelin Contracts v5.0+
import "@openzeppelin/contracts/utils/Counters.sol";

contract Thump is Initializable, ERC721Upgradeable, ERC721URIStorageUpgradeable, ERC721EnumerableUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using Counters for Counters.Counter;

    Counters.Counter private _nextTokenId;
    uint256 public  _totalSupply;
    uint256 public constant MAX_PER_ADDRESS_DURING_MINT = 10;
    bool public mintIsActive;
    mapping(address => uint256) private _mintedCount;
    uint256 public mintPrice;
    string private baseMetadataURI;

    event NFTMinted(address indexed to, uint256 indexed tokenId, string tokenURI);
    event TokenURIUpdated(uint256 indexed tokenId, string newTokenURI);

    function initialize() public initializer {
        __ERC721_init("THUMPS", "THUMP");
        __ERC721URIStorage_init();
        __ERC721Enumerable_init();
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();

        _nextTokenId.increment(); // Start token IDs at 1
        _totalSupply = 538;
        mintIsActive = false;
        mintPrice = 1 ether;
        baseMetadataURI = "https://blokesofhytopia.netlify.app/.netlify/functions/metadata/";
    }

    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable, ERC721EnumerableUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setMintPrice(uint256 newPrice) public onlyOwner {
        mintPrice = newPrice;
    }

    function setTotalSupply(uint256 newSupply) public onlyOwner {
        _totalSupply = newSupply;
    }

    function setBaseMetadataURI(string memory newBaseMetadataURI) public onlyOwner {
        baseMetadataURI = newBaseMetadataURI;
    }

    function normalMint(address to) public payable nonReentrant {
        require(mintIsActive, "Mint is not active");
        require(msg.value == mintPrice, "Incorrect ETH value sent");
        require(_nextTokenId.current() <= _totalSupply, "Total supply reached");
        require(balanceOf(to) < MAX_PER_ADDRESS_DURING_MINT, "Cannot mint more than allowed per address");
        _processMint(to);
    }

    function _processMint(address to) internal {
        uint256 tokenId = _nextTokenId.current();
        _nextTokenId.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, string(abi.encodePacked(baseMetadataURI, Strings.toString(tokenId))));
        _mintedCount[to]++;
        emit NFTMinted(to, tokenId, string(abi.encodePacked(baseMetadataURI, Strings.toString(tokenId))));
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._increaseBalance(account, value);
    }

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function updateTokenURI(uint256 tokenId, string memory newUri) public onlyOwner {
        _setTokenURI(tokenId, newUri);
        emit TokenURIUpdated(tokenId, newUri);
    }

    function getNextTokenId() public view returns (uint256) {
        return _nextTokenId.current();
    }

    function setMintActive(bool _active) public onlyOwner {
        mintIsActive = _active;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = owner().call{value: balance}("");
        require(success, "Transfer failed.");
    }

    function airdropMint(address to) public onlyOwner {
        require(_nextTokenId.current() <= _totalSupply, "Total supply reached");
        _processMint(to);
    }
}