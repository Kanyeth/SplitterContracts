pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract NFTSplitter is ERC721URIStorage, Ownable, IERC721Receiver {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;





    constructor() public ERC721("Split token", "SPLT") {}

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }



    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) public virtual override returns (bytes4) {
        mintNFT(operator, "OWN");
        mintNFT(toAddress(data, 0), "USE");
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