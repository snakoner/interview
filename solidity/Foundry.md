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
