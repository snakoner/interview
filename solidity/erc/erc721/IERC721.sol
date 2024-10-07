// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IERC721 {
    // передача владения nft от from к to
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    // разрешение управлять nft адресу approved, который принадлежит owner
    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);
    // разрешение для operator управлять всеми nft owner
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // сколько nft есть на балансе owner
    function balanceOf(address owner) external view returns(uint);
    // кто владеет заданным токеном
    function ownerOf(uint tokenId) external view returns(address);

    function safeTransferFrom(address from, address to, uint tokenId) external;
    function transferFrom(address from, address to, uint tokenId) external;
    // разрешаем распоряжаться nft
    function approve(address to, uint tokenId) external;
    // разрешаем распоряжаться всеми nft
    function isApprovedForAll(address operator, bool approved) external;
    // кто может распоряжаться токеном
    function getApproved(uint tokenId) external view returns(address);
    // может ли operator распоряжаться токенами owner
    function isApprovalForAll(address owner, address operator) external view returns(bool);    
}
