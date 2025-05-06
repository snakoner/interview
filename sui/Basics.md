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
    // конструктор, обязательно с названием init
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

    // эмуляция транзакция с помощью test_scenario
    #[test]
    fun test_counter_transactions() {
        use sui::test_scenario;
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let mut scenario = test_scenario::begin(initial_owner);
        {
            let counter  = counter_create(scenario.ctx());
            transfer::public_transfer(counter, initial_owner);
        };

        scenario.next_tx(initial_owner);
        {
            let counter = scenario.take_from_sender<Counter>();
            transfer::public_transfer(counter, final_owner);
        };

        scenario.next_tx(final_owner);
        {
            let counter = scenario.take_from_sender<Counter>();
            assert!(counter.counter == counter.counter(), 1);
            scenario.return_to_sender(counter);
        };

        scenario.end();
    }
}
```

### Сборка и Тестирование
1. sui move build
2. sui move test
3. sui move test counter (will call only #test with 'counter' word in function name)


### entry - изменяет состояние блокчейна
