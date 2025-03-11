# Оглавление
- [Сборка проекта](#сборка-проекта)
- [Переменные](#переменные)
    - [Скалярные](#скалярные)
    - [Композитные](#композитные)
    - [Преобразование базовых типов](#преобразование-базовых-типов)
    - [Константы](#константы)
    - [HashMap](#hashmap)
- [Функции, операторы, циклы](#функции-операторы-циклы)
    - [Функция](#функция)
    - [if / else / else if](#if-else-else-if)
    - [match](#match)
    - [loops](#loops)

- [Заключение](#заключение)

# Сборка проекта
## Cargo

Создание:
```bash
cargo new <project-name>
```

Запуск:
```
cd project-name
cargo run
```

## Hello world
```rust
fn main() {
    println!("Hello, world!");
}
```

# Переменные
## Скалярные:
- u8 / u16 / u32 / u64 / u128
- i8 / i16 / i32 / i64 / i128
- isize // arch dependent (like int in C)
- usize // Используется для индексов и длины массивов
- f32/f64
- bool
- char // **Unicode!!!**

```rust
let x = 12; // by default this is i32
let a = 12u8;
let b = 4.3; // by default this is f64
let c = 4.3f32;
```

## Композитные:
- Кортежи: могут содержать элементы разных типов.
```rust
let my_tuple: (i8, char, bool) = (1, 'f', false);
let i_var: i8 = my_tuple.0;
```

- Array (static)
```rust
let arr: [i32; 3] = [1,2,3];
println!("{:?}", arr); // [1,2,3]

// получение элемента
let elem0: i32 = arr[0];

// заполнение массива
let ones: [i32; 5] = [1; 5];  // Создаст [1, 1, 1, 1, 1]

// срез
let slice = &arr[1..3];  // Получаем [2, 3]

// итерирование
for arr in arr.iter() {
    println!("{}", num);
}

```

- Vector (dynamic)
```rust
let mut v: Vec<i32> = Vec::new();
v.push(10);
v.push(20);
v.push(30);
println!("{:?}", v);  // [10, 20, 30]

let v = vec![1, 2, 3, 4, 5];
let last = v.pop();  // Удалит последний элемент и вернет его

for num in &v {
    println!("{}", num);
}

v.swap(0, 1); // v[0], v[1] = v[1], v[0]
```

- String / &str
- `&str` – строковый срез (string slice):
  - Это ссылка на строку, которая хранится в памяти где-то еще (например, в статической памяти или внутри String):
  - Плюсы: Использует меньше памяти, не требует аллокаций в куче.
  - Минусы: Нельзя изменять.

```rust
fn main() {
    let s: &str = "Hello, world!"; // Статическая строка в коде
    println!("{}", s);
}
```

- `String` –
    - Изменяемая строка, которая хранится в куче и может изменять размер.
    - Плюсы: Гибкость, возможность модификации.
    - Минусы: Требует аллокаций в куче, может быть менее производительным.

```rust
fn main() {
    let mut s = String::from("Hello");
    s.push_str(", world!"); // Можно изменять строку
    println!("{}", s);
}
```


## Преобразование базовых типов
```rust
fn main() {
    let a = 13u8;
    let b = 7u32;
    let c = a as u32 + b;
    println!("{}", c);

    let t = true;
    println!("{}", t as u8);
}
```

## Константы
Вместо копирования значения, как в случае переменных, константа напрямую заменяет текстовый идентификатор в месте ее использования на значение константы во время компиляции (#define в C)

```rust
const PI: f32 = 3.14159;
```

### HashMap
```rust

fn two_sum(vec: &Vec<i32>, target: i32) -> Vec<i32> {
    let mut map = HashMap::new();

    for i in 0..vec.len() {
        let difference = target - vec[i];
        if let Some(x) = map.get(&difference) {    // в x будет value если существует ключ
            return vec![*x, i as i32];
        } else {
            map.insert(vec[i], i as i32);
        }
    }

    return vec![-1, -1];
}
```

1. Импорт:
```rust
use std::collections::HashMap;
```

2. Создать и добавить элементы
```rust
let mut map = HashMap::new();

map.insert("apple", 3);
map.insert("banana", 5);
map.insert("orange", 2);

println!("{:?}", map);
```

3. Получить значение по ключу:
```rust
if let Some(value) = map.get("apple") {
    println!("Apple count: {}", value);
}
```

4.	Удалить элемент:
```rust
map.remove("banana");
```

5.	Перебрать все элементы:
```rust
for (key, value) in &map {
    println!("{}: {}", key, value);
}
```

6.	Проверить наличие ключа:
```rust
if map.contains_key("orange") {
    println!("Есть апельсин!");
}
```

7.	Использование entry для вставки, если ключ отсутствует:
```rust
map.entry("grape").or_insert(10);
```

# Функции, операторы, циклы

## Функция

Точка входа в программу:
```rust
fn main() {
}
```

```rust
fn test(value: i8) -> i8 {
  value + 1 // if no ; -> returns automatically
}
```

## if / else / else if

```rust
fn main() {
  let i: i32 = 1;
  if i == 1 {
    println!("true");
  } else if i == 2 {
    println!("false");
  } else {
    println!("none");
  }
}
```

## match
```rust
fn main() {
    let x = 42;

    match x {
        0 => {
            println!("found zero");
        }
        // we can match against multiple values
        1 | 2 => {
            println!("found 1 or 2!");
        }
        // we can match against ranges
        3..=9 => {
            println!("found a number 3 to 9 inclusively");
        }
        // we can bind the matched number to a variable
        matched_num @ 10..=100 => {
            println!("found {} number between 10 to 100!", matched_num);
        }
        // this is the default match that must exist if not all cases are handled
        _ => {
            println!("found something else!");
        }
    }
}
```

## loops
1. loop - бесконечный цикл, остановка с помощью break

```rust
    let mut i: i32 = 0;
    loop {
        if i == 32 {
            break;
        }

        i += 1;
    };
```


Можно возвращать значение из break:
```rust
    let mut i: i32 = 0;
    let res: i32 = loop {
        if i == 32 {
            break i;
        }

        i += 1;
    };

    println!("{}", res); // 32
```

2. while

```rust
let mut counter: i32 = 0;

while counter < 10 {
  counter += 1;
}
```

3. for
```rust
let arr: [i32; 5] = [1,2,3,4,5];

for el: i32 in arr {
  println!("{}", el);
}
```

```rust
for i in 0..5 {
  println!("{}", i);
}

// 5 включается
for i in 0..=5 {
  println!("{}", i);
}
```
