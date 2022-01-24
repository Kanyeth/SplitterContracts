pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract CreditManager is ERC721URIStorage, Ownable, IERC721Receiver {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct NFT {
        address contractAddress;
        uint256 tokenId;
    }

    struct Deal {
        address author;
        uint128 interestRate;
        uint256 initialPayment;
        uint256 timelock;
        address ERC721Address;
        uint256 tokenId;
        bool isActive;
    }

    Deal[] public deals; 

    address splitterContract = 0x8a7644191756a1122A63C0CA7238A8f15706f825;


    constructor() public ERC721("Debt token", "DBT") {}

    function toUint256(bytes memory _bytes)  internal pure returns (uint256 value) {
        assembly {
            value := mload(add(_bytes, 0x20))
        }
    }



    function addDeal(uint128 interestRate, uint256 timelock, uint256 initialPayment, address ERC721Address, uint256 tokenId) public {
        ERC721 token = ERC721(ERC721Address);
        require(token.ownerOf(tokenId) == msg.sender, "Not the owner!");
        require(token.isApprovedForAll(msg.sender, address(this)), "Not approved!");
        deals.push(Deal(msg.sender, interestRate, initialPayment, timelock, ERC721Address, tokenId, false));
    }


    function acceptDeal(uint256 dealId) public payable { 
        require(msg.value == deals[dealId].initialPayment);
        ERC721 token = ERC721(deals[dealId].ERC721Address);
        token.safeTransferFrom(deals[dealId].author, splitterContract, deals[dealId].tokenId, abi.encodePacked(msg.sender));
        mintNFT(deals[dealId].author, "Debt collector");
        deals[dealId].isActive = true;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }


    function mintNFT(address recipient, string memory tokenURI)
        internal
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

}