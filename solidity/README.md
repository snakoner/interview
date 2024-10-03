1. Чтобы контракт мог принимать деньги, нужно, чтобы в нем была объявлена функция receive (название может быть другое, в теле можно ничего не указывать):

```solidity
    receive() external payable { }
```

2. Отправить деньги из контракта на адрес можно так:

```solidity
function withdraw() public {
  address payable recepient = payable(msg.sender);
  (bool success, ) = recepient.call{value: amount}("");

  // в случае нехватки эфира на контракте транзакция откатится назад, то есть она выполняется как атомарная операция.
  require(success);
}
```
