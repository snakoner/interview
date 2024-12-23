### Light

1. Что такое смартконтракт?
> Кусок кода, который развернут в бч, с которой мы можем взаимодействовать (отправлять транзакции, модифицировать данные) и который может взаимодействовать с другими ск.
2. Особенности смартконтрактов?
> Если контракт был развернут в бч, то его исходный код изменить нельзя
3. Могут ли контракты взаимодействовать с друг другом?
> Да, но сами инициировать транзакции не могут, только с аккаунта
4. На каких языках пишутся смартконтракты?
> Solidity, Viper (уже не используется), Yul - более низкоуровневый
5. Типизация
> Статическая
6. Компилируемый ли Solidity?
> Да
7. Можно ли в одном файле писать несколько ск?
> Да
8. Что содержит в себе смарт контракт?
> License, pragma, Имя, state variables, modifiers, events, structs, enums, constructor, functions
9. Разница между state variables и local variables?
> state - хранятся в storage, то есть в блокчейне, видны в любом месте смарт контракта. local variables - видны в пределах вызова функции.
10. Что такое variable shadowing?
```solidity
contract Test {
  uint password;

  // 1: function argument has the same naming
  function setPassword(uint password) external {}
  // 2: local variable has the same naming
  function incPassword() external {
    uint password;
  }
}
```
11.  Разница между private, public:
> Для public переменный solc генерирует одноименные getter функции с модификатором public. Но private все равно можно прочитать из слота. Private не наследуется.
12. Какая область видимости не может быть назначена для state variable?
> external
13. Какая область видимость у state variables?
> private
14. Как защитить приватные данные в блокчейне?
> Хранить хэши и использовать паттерн commit reveal
15. Что такое address?
> Специальный тип данных, 160 бит, записывается в 16-ричном виде, бывают обычные и payable - сюда можно отправлять денежные средства с помощью transfer, send. С call можно без payable.
16. Что такое selfdestruct?
> - selfdestruct(address payable recipient): Код контракта и его данные удаляются из состояния блокчейна
> - Все средства с баланса контракта автоматически отправляются на адрес, указанный в параметре recipient
> - После вызова selfdestruct взаимодействовать с контрактом становится невозможно
> - При удалении контракта возвращается часть затрат на газ (до 24 000 gas).
17. Как обойти mapping?
> Никак, можно создать массив с ключами
18. Как откатить транзакцию?
> - require(condition, "msg"),
> - if (cond) revert("msg"); или if (cond) revert(err), где err - error CustomError(address account)
> - assert(cond) - откатывается с состоянием panic, газ не возвращается.
19. Что такое ABI?
>  Описывает какие есть переменные и функции, их типы и имена. В формате json
20. Что такое байткод?
> То, что разворачивается в блойчейне, состоит из opcodes, constants, immutable.
21. Понимает ли EVM solidity?
> Нет, понимает только байткод
22. Какие функции не попадут в ABI?
> private, internal функции и переменные.
23. Что такое gas?
> Сколько единиц потратится на выполнение транзакции. Заранее предопределен. gasLimit - сколько готов потратить на выполнение транзакции, gasPrice - меняется динамически.
24. Отличие call от транзакции?
> call - read (не платим за газ), транзакции - меняют состояние (платим за газ)
25. Нужно ли платить доп газ, если в транзакции вызывается read функция?
> Да
26. Что, если газ закончится?
> Транзакция будет откачена
27. В какие сети можно разворачивать смартконтракты:
> mainnet, testnets: holesky, sepolia
28. Как породить событие?
> emit, хранится в логах блока, в котором эта транзакция была выполнена
29. Может ли контракт читать события?
> Нет, только извне
30. Может ли контракт удалять события из бч?
> Нет
31. Можно ли использовать console log?
> Нет: hardhat, события
32. Можно ли вернуть длину для строки?
> Нет, можно модифицировать в bytes -> bytes.length

### Hard
1. Как работать со структурой, которая содержит mapping?
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Test {
    struct Person {
        string name;
        mapping (address => uint) payments;
    }

    Person[] persons;

    function addPerson(string memory _name) external {
        Person storage newPerson = persons.push();
        newPerson.name = _name;
        newPerson.payments[address(this)] = 10;
    }    
}
```
2. Как создать массив в memory?
> uint[] memory array = new uint[](size);
3. Как создать mapping в memory?
> Никак
4. Может ли mapping быть аргументом или выходным значением?
> Нет
5. Что будет, если запросить несуществующий индекс в массиве? А в mapping?
> В массиве: revert. В mapping - вернет дефолтное значение
6. Механизмы повторного использования кода
> функции, наследование, абстрактные контракты, библиотеки
7. Как выполняется перегрузка функций?
> virtual
8. Как вызвать функцию родителя?
> Parent.doWork(), super.doWork()
9. Как создать новый контракт в контракте и получить его адрес?
```solidity
// Здесь Child - другой контракт, функция объявлена в Parent
function createContract() external {
  address newContract = address(new Child());
}
```
10. Как формируется адрес контракта
> - Зависит от msg.sender, nonce - сколько транзакций было отправлено в msg.sender
> - Есть механизм create2: address newContract = address(new Child{salt: _salt}());, где _salt - bytes32. То есть теперь зависит от msg.sender, байткода Child, salt
11. Как формируется адрес аккаунта?
> - Генерация приватного ключа: 0x1c8e0aace34f5c0b92dbd5b1b2b2f2d2e3f4f5f6a7a8a9b0c0d0e0f1f2f3f4f5
> - Получение публичного ключа (ECDSA): 0x04bfcab22c87b7d54c3d542deca60b02dc6c0d2bf65b5f6b01f4c72d7432234bf3ad0bfa4cc4e3e6374c49afbd3d47babc
> - keccak256(public_key) и берем последние 20 байт
12. Как сделать низкоуровневый вызов call:
> - (bool success, bytes memory response) = _to.call{value: 1 ether}(abi.encodeWithSignature("pay(uint256)", 42));
> - (bool success, bytes memory response) = _to.call{value: 1 ether}(abi.encodeWithSignature(Child.pay.selector, 42)); // если есть код
13. Отличие tx.origin, msg.sender
> - tx.origin: кто изначально инициировал транзакцию
> - msg.sender: кто последний вызвал транзакцию - может быть контрактом.
14. keccak256
> Выход bytes32.
15. Что такое indexed и как он связан с topics?
> 
