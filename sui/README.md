### 1. Что такое let Counter { id, owner: _, value: _ } = counter;

Эта запись на языке Move (и в частности в Sui Move) — это деструктуризация структуры, то есть разложение полей структуры Counter на отдельные переменные.

### 2.  #[test_only],  #[test]

#### #[test]
- Используется для обозначения тестовой функции.
- Эти функции выполняются при запуске sui move test.
- Они выполняются как обычный unit test и могут вызывать другие обычные функции и test_only функции.

 #### #[test_only]
- Используется для обозначения функций или модулей, которые можно вызывать только из #[test].
- Такие функции не могут быть вызваны в entry fun или обычной public fun, если вызов происходит в боевом коде.
- Помогает ограничивать вспомогательные функции только для тестов, т.е. они не попадут в продакшн-использование.

### 3. public fun vs public entry fun
- public fun - может быть вызвана только из других Move-функций
- public entry fun - можно вызывать напрямую через tx

### 4. merge tokens, split tokens

#### merge
Сливает несколько объектов Coin<T> в один общий объект, суммируя их значения:

```move
let merged = coin::merge(vector[coin1, coin2], ctx);
```

- coin1 = 1 SUI
- coin2 = 2 SUI
- merged = 3 SUI (новый объект, coin1 и coin2 уничтожаются)

#### split
Разделяет один Coin<T> на два: один с заданной суммой, второй — с остатком.

```move
let part = coin::split(&mut my_coin, 1_000_000_000, ctx); // 1 SUI
```

- my_coin было 3 SUI → станет 2 SUI
- part будет 1 SUI


### 5. share_object
Менять поля shared object в Sui вне функций, определённых в контракте, невозможно.

Это принципиальное ограничение модели безопасности Sui и языка Move. Все изменения shared-объектов должны происходить строго через публичные entry функции модуля, где объект определён.

### 6. Получение текущего времени
С sui за время отвечает отдельный модуль 0x2::clock, поэтому если нужно использовать время в функции sui, то нужно передать immutable ссылку в функцию:

```move
public fun get_time(clock: &Clock): u64 {
  clock.timestamp_ms() / 1000
}
```

### 7. Function visibility


### 8. key, store, copy, drop
#### key
Обозначает, что структура — объект, хранящийся в глобальном хранилище.

Требуется для использования с:
- object::new
- transfer::transfer
- borrow_global, borrow_global_mut
- object::id, UID
  
Без key нельзя сохранить объект в блокчейн.

#### store
Разрешает сохранять структуру в хранилище, например:
- в глобальные объекты
- в поля других структур

Если у типа нет store, ты не можешь вложить его в **объект** или **vector**.

#### copy
Разрешает копировать значения этого типа.

В структуре с модификатором copy не может быть UID, object, vector<Coin<T>>

#### drop
Возможность удалять объект неявно.
```move
struct SensitiveData {
    secret: u64,
}

// Нельзя просто проигнорировать:
let data = get_secret(); // возвращает SensitiveData: value not used and doesn't have drop ability
```

### 9. entry 
An **entry function** can be called in PTBs but not in other Sui packages.

### 10. friend 


### 11. table.borrow(key) в случае, если key нет вызовет transaction revert
Чтобы проверить есть ли ключ в table, нужно:
```move
 let is_contains = table::contains(&t, key)
```

### 12. Move.toml
```bash
[package]
name = "suilend"
version = "0.0.1"
published-at = "0x43d25be6a55db4e7cc08dd914b8326e7d56fb64c67f0fb961a349e2872f4cc08" # last version


[addresses]
sui = "0x2"
# suilend = "0x0"
suilend = "0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf" # version 1
