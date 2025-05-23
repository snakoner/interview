1. Обновление логики контракта:
```bash
sui client upgrade --upgrade-capability 0xbc3c67f43246d482a6e85aade53619e2b11834ee70131c03f0e6f62d80dc4897
```

Создастся новый пакет с новым ID, теперь из своего контракта можно обращаться как к первому контракту, так и ко второму.

2. Вызов функции контракта
```bash
sui client call --package 0xb153c586fe0695141dbeafaa99813c4d3a9cc34fb8434db8ad5c6f76e7375f7e --module counter --function increment --args 0x440ce5ce70c089b1c07e672f0da3d69f0c38c3c3c561d6e14ea672f8aaba20db
```

Это пример вызова функции 

```move
module counter::counter {
    public fun increment(counter: &mut Counter) {
        counter.value = counter.value + 2;
    }
}
```

3. Добавление приватника:
```bash
sui keytool import suiprivkey1... ed25519
```

4. Разделение монет:
```bash
sui client split-coin --coin-id 0x8549ffc5fa5316754d833fe186685c19ee05aac225064a2c572a62c0110f78de --amounts 1000000
```
