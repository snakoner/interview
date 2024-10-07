// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC721Metadata.sol";

// контракт получателя nft должен реализовывать данный интерфейс
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data) 
    external returns(bytes4);
    // return IERC721Receiver.onERC721Received.selector; - хочу принимать nft
    // revert - не хочу принимать nft
}
