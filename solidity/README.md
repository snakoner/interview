1. Чтобы контракт мог принимать деньги, нужно, чтобы в нем была объявлена функция receive (в теле можно ничего не указывать):

```sol
    receive() external payable { }
```

2. Отправить деньги из контракта на адрес можно так:

```sol
function withdraw() public {
  address payable recepient = payable(msg.sender);
  (bool success, ) = recepient.call{value: amount}("");

  // в случае нехватки эфира на контракте транзакция откатится назад, то есть она выполняется как атомарная операция.
  require(success);
}
```
