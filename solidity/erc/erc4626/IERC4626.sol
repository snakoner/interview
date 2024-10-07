// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC20.sol";

interface IERC4626 is IERC20 {
    event Deposit(
        address indexed sender,
        address indexed owner,
        uint assets,
        uint shares
    );

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint assets,
        uint shares
    );

    // получить адрес токена, который можно вкладывать и забирать
    function asset() external view returns(address assetTokenAddress);

    // сколько на данный момент вложено
    function totalAssets() external view returns(uint totalManagedAssets);

    // конвертация assets в shares
    function convertToShares(uint assets) external view returns(uint shares);

    // конвертация shares в assets
    function convertToAssets(uint shares) external view returns(uint assets);

    // сколько можно вложить за 1 транзакцию
    function maxDeposit(address receiver) external view returns(uint maxAssets);

    // показывает, сколько долей я получу
    function previewDeposit(uint assets) external view returns(uint shares);

    // кладет указанное количество токенов, создает shares долей
    function deposit(uint assets, address receiver) external returns(uint shares);

    function maxMint(address receiver) external view returns (uint256 maxShares);

   
    function previewMint(uint256 shares) external view returns (uint256 assets);
   
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    // забираем assets, сжигает shares
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    function maxRedeem(address owner) external view returns (uint256 maxShares);

    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    // сколько долей я хочу сжечь
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}
