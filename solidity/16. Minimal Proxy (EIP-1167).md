Вместо того чтобы копировать всю логику в каждый новый контракт, minimal proxy содержит лишь небольшую часть кода, который:
1. Перенаправляет (delegates, через fallback) вызовы в основной (реализующий, template) контракт.
2. Хранит адрес этого контракта.
3. Использует delegatecall, чтобы выполнять код реализации в контексте прокси.
4. Если реализуемая функция есть в clone, то будет вызвана она, так как не попадем в fallback.

Каждый клон будет проксировать вызовы в `implementation`, но при этом будет иметь свой собственный `storage`.

Path: `"@openzeppelin/contracts/proxy/Clones.sol"`

- `clone(address implementation) → address`
  - Разворачивает новый минимальный прокси-контракт.
- `clone(address implementation, bytes32 salt) → address`
  - Создаёт минимальный прокси по предсказуемому адресу (используется CREATE2).  
  - Полезно для кроссчейн-совместимости и масштабирования.
- `predictDeterministicAddress(address implementation, bytes32 salt) → address`
  - Позволяет предсказать адрес прокси до его развёртывания.


### Что происходит при clone
Байт-код minimal proxy:
- 3d602d80600a3d3981f3363d3d373d3d3d363d73**bebebebebebebebebebebebebebebebebebebebe**5af43d82803e903d91602b57fd5bf3

1. 3d602d80600a3d3981f3 - init code, используется при деплое контракта и сохраняет runtime байт-код контракта, начиная с 10-го байта.
2. 363d3d373d3d3d363d73 - copy calldata в memory
3. bebebebebebebebebebebebebebebebebebebebe - при деплое контракта этот адрес заменяется адресом логики, куда будет происходить delegatecall
4. 5af43d82803e903d91602b57fd5bf3 - delegatecall + возвращение результата вызова.

> В minimal proxy есть `fallback()`, в котором и происходит вышеописанные действия.
