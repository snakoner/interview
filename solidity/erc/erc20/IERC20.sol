
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IERC20 {
    // функции, которые не являются частью стандарта, то желательно реализовывать
    // полное имя токена
    function name() external view returns(string memory);
    // краткое имя токена
    function symbol() external view returns(string memory);
    // количество знаков после запятой
    function decimals() external pure returns(uint);

    // функции, которые являются частью стандарта
    // число токенов (в теории, можно минтить новые токены)
    function totalSupply() external view returns(uint);
    // число токенов у аккаунта
    function balanceOf(address account) external view returns(uint);
    // функция для пересылки токенов от вызывающего на другой аккаунт
    function transfer(address to, uint amount) external;

    // функция для того, чтобы владелец кошелька позволил забрать другому адресу какое-то число токенов в пользу третьего лица
    // например, spender - стороний контракт
    function allowance(address _owner, address _spender) external view returns(uint);

    // кто может списывать токены и в каком количестве
    function approve(address spender, uint amount) external;

    // функция для списывания токенов с sender и отдать их recipient
    function transferFrom(address sender, address recipient, uint amount) external;

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approve(address indexed owner, address indexed to, uint amount);
}  
