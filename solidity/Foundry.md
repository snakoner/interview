1. Создание проекта:
```bash
forge init my_project
```

```
my_project/
├── foundry.toml   # Конфигурация проекта
├── lib/           # Зависимости (аналог node_modules)
├── script/        # Скрипты для деплоя
├── src/           # Контракты
│   ├── Counter.sol
├── test/          # Тесты
│   ├── Counter.t.sol
```

```bash
anvil --fork-url $FOUNDRY_RPC_URL --fork-block-number 22122478
```

2. Установка библиотек:
```bash
forge install OpenZeppelin/openzeppelin-contracts
```
3. Компиляция контракта:
```bash
forge build
```  

4. Написание тестов:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Counter.sol";

contract CounterTest is Test {
    Counter counter;

    function setUp() public {
        counter = new Counter();
    }

    function testIncrement() public {
        counter.increment();
        assertEq(counter.count(), 1);
    }

    function testDecrement() public {
        counter.increment();
        counter.decrement();
        assertEq(counter.count(), 0);
    }
}
```

```bash
forge test
forge test --fork-url $FOUNDRY_RPC_URL -vvv
```

5. Запуск локальной сети (Anvil):
```bash
export FOUNDRY_RPC_URL=${ETHEREUM_RPC}
```

```bash
anvil --fork-url $FOUNDRY_RPC_URL --fork-block-number 22122478
```

6. Чтобы запускать тест, нужно, чтобы имя функции test[FuncName]

7. Как минтить токены?
```solidity
// mint
myWallet = address(this);
bytes32 slot;

// for certain token have to find out basic slot for mapping (address => uint256) balances:
slot = keccak256(abi.encode(myWallet, uint256(3)));
vm.store(GHO, slot, bytes32(uint256(10 ** 24)));
uint256 balance = IERC20(GHO).balanceOf(myWallet);
```
8. Выполнение транзакции от другого адреса:
```solidity
vm.startPrank(ADDRESS);
vm.stopPrank(); // обязательно, если хотим переключить на другой адрес дальше
vm.startPrank(myWallet);
```

9. Создание форка от mainnet:
```bash
function setUp() public {
    vm.createSelectFork(vm.envString("FOUNDRY_RPC_URL"));
}
```

10. Намайнить блоков:
```bash
vm.warp(block.timestamp + 1 days);
```
