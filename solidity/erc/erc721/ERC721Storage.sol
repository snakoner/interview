// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./ERC721.sol";

contract ERC721Storage is ERC721 {
    mapping(uint => string) _tokenURIs;

    function tokenURL(uint tokenId) public view virtual override _requireMinted(tokenId) returns(string memory) {
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory _base = _baseURI();

        if (bytes(_base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return abi.encodePacked(_base, _tokenURI);
        } 

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint tokenId, string memory _tokenURI) internal virutal _requireMinted(tokenId) {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function burn(uint tokenId) public override _requireMinted(tokenId) {
        super.burn(tokenId);
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
