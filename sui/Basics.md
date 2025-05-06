Контракт начинается так:
```move
module example::counter {}
```

В Move.toml нужно явно указать:
```
[addresses]
example = "0x0" // или любой другой hex
```

Таким образом:
- example — это адрес, под которым будет опубликован контракт (обычно 16-ричное значение, например 0x123).
- counter — это имя модуля, которое ты сам выбираешь.
- В Sui (и Move в целом), каждый модуль жёстко привязан к адресу владельца.

Вместе example::counter — это уникальный идентификатор модуля в блокчейне Sui для конкретного адреса (то есть адрес формируется из 0x0::example, EOA address).


Пример контракта counter:

```move
module counter::example {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    public struct Counter has key, store {
        id: UID,
        counter: u64,
    }

    fun init(ctx: &mut TxContext) {
        let counter = Counter {
            id: object::new(ctx),
            counter: 0,
        };

        transfer::transfer(counter, ctx.sender());
    }

    public fun counter(self: &Counter): u64 {
        self.counter
    }

    // object cant be just dissapear -> need to transfer ownership
    #[test]
    fun test_counter_access() {
        let mut ctx = tx_context::dummy();
        let counter = Counter {
            id: object::new(&mut ctx),
            counter: 0,
        };

        assert!(counter.counter == counter.counter(), 1);

        let dummy_address = @0xCAFE;
        transfer::transfer(counter, dummy_address);
    }
}
```

### Сборка и Тестирование
1. sui move build
2. sui move test
3. sui move test counter (will call only #test with 'counter' word in function name)
