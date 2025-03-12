Вместо того чтобы копировать всю логику в каждый новый контракт, minimal proxy содержит лишь небольшую часть кода, который:
1. Перенаправляет (delegates) вызовы в основной (реализующий) контракт.
2. Хранит адрес этого контракта.
3. Использует delegatecall, чтобы выполнять код реализации в контексте прокси.

Каждый клон будет проксировать вызовы в `implementation`, но при этом будет иметь свой собственный `storage`.

Path: `"@openzeppelin/contracts/proxy/Clones.sol"`

- `clone(address implementation) → address`
  - Разворачивает новый минимальный прокси-контракт.
- `clone(address implementation, bytes32 salt) → address`
  - Создаёт минимальный прокси по предсказуемому адресу (используется CREATE2).  
  - Полезно для кроссчейн-совместимости и масштабирования.
- `predictDeterministicAddress(address implementation, bytes32 salt) → address`
  - Позволяет предсказать адрес прокси до его развёртывания.
