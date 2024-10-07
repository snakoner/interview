
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";

contract ERC721 is IERC721Metadata, IERC721Receiver {
    using Strings for uint;
    string public name;
    string public symbol;
    mapping(address => uint) _balances;
    mapping(uint => address) _owners;
    mapping(uint => address) _tokenApprovals;
    mapping(address => mapping(address => bool)) _operatorApprovals;

    modifier _requireMinted(uint tokenId) {
        require(_exists(tokenId), "not minted");
        _;
    }

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function _baseURI() internal pure virtual returns(string memory) {

    }

    function tokenURI(uint tokenId) public view virtual _requireMinted(tokenId) returns(string memory) {
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }


    function _exists(uint tokenId) internal view returns(bool) {
        return _owners[tokenId] != address(0);
    }

    function balanceOf(address owner) public view returns(uint) {
        require(owner != address(0), "zero address");
        return _balances[owner];
    }


    function transferFrom(address from, address to, uint tokenId) external {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _transfer(from, to, tokenId);
    }


    function safeTransferFrom(address from, address to, uint tokenId) external {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _safeTransfer(from, to, tokenId);
   }

    function _isApprovedOrOwner(address spender, uint tokenId) internal view returns(bool) {
        address owner = ownerOf(tokenId);
        require(
            spender == owner || 
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender,
            "not an owner or approved");
    }

    function _safeTransfer(address from, address to, uint tokenId) internal {
        _transfer(from, to, tokenId);

        // может ли to владеть nft (если смартконтракт не может владеть nft)
        require(_checkOnERC721Received(from, to, tokenId), "non erc721 receiver");
    }

    function _transfer(address from, address to, uint tokenId) internal {
        require(ownerOf(tokenId) == from, "from dont own nft");
        require(to != address(0), "zero address");

        _beforeTokenTransfer(from, to, tokenId);
        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
        _afterTokenTransfer(from, to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint tokenId) internal virtual {}

    function _checkOnERC721Received(address from, address to, uint tokenId) private view returns(bool) {
        // if smart contract
        if(to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, bytes("")) returns(bytes4 ret) {
                return ret == IERC721Receiver.onERC721Received.selector;
            } catch(bytes memory reason) {
                if (reason.length == 0) {
                    revert("non erc721 receiver");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }

            }
        } else {
            return true;
        }
    }

    function ownerOf(uint tokenId) public view _requireMinted(tokenId) returns(address) {
        return _owners[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns(bool) {
        return _operatorApprovals[owner][operator];
    }

    function getApproved(uint tokenId) public view _requireMinted(tokenId) returns(address) {
        return _tokenApprovals[tokenId];
    }

    function approve(address to, uint tokenId) public _requireMinted(tokenId) {
        address owner = ownerOf(tokenId);
        require(owner == msg.sender || isApprovedForAll(owner, msg.sender), "not an owner and not approved");
        require(to != owner, "is owner");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }


    function _safeMint(address to, uint tokenId) internal virtual {
        _mint(to, tokenId);

        require(_checkOnERC721Received(msg.sender, to, tokenId), "non erc721 receiver");
    }
    
    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "zero address");
        require(!_exists(tokenId), "already exists");

        _owners[tokenId] = to;
        _balances[to]++;
    }

    function burn(uint tokenId) public _requireMinted(tokenId) {
        require(_isApprovedOrOwner(msg.sender, tokenId));
        delete _tokenApprovals[tokenId];
        _balances[msg.sender]--;

        _owners[tokenId] = address(0);
    }

}
