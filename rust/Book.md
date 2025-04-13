# Оглавление
- [Сборка проекта](#сборка-проекта)
- [Переменные](#переменные)
    - [Скалярные](#скалярные)
    - [Композитные](#композитные)
        - [Tuple](#tuple)
        - [Static array](#static-array)
        - [Vector](#vector)
        - [String / &str](#string--str)
        - [Slice](#slice)
    - [Преобразование базовых типов](#преобразование-базовых-типов)
    - [Константы](#константы)
    - [HashMap](#hashmap)
    - [Variable shadowing](#variable-shadowing)
- [Функции, операторы, циклы](#функции-операторы-циклы)
    - [Функция](#функция)
    - [if](#if)
    - [match](#match)
    - [loops](#loops)

- [Ownership](#ownership)
    - [Примеры владения](#примеры-владения)
    - [Итого](#итого)
- [Struct, impl, enum](#struct-impl-enum)
    - [Struct](#struct)
    - [Enums](#enums)
    - [Более сложные Enum](#более-сложные-enum)
    - [Impl для Enum](#impl-для-enum)
- [Option, Some, None](#option-some-none)
- [Traits](#traits)
    - [Что такое](#что-такое)
    - [Дефолтная реализация методов](#дефолтная-реализация-методов)
- [Generic Types](#generic-types)
- [Указатели](#указатели)

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
### Tuple
- Кортежи: могут содержать элементы разных типов.
```rust
let my_tuple: (i8, char, bool) = (1, 'f', false);
let i_var: i8 = my_tuple.0;
```

### Static array
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

### Vector
```rust
let mut v1: Vec<i32> = Vec::new();
v1.push(10);
v1.push(20);
v1.push(30);
println!("{:?}", v1);  // [10, 20, 30]

let mut v2 = vec![1, 2, 3, 4, 5];
let last = v2.pop();  // Удалит последний элемент и вернет его

for num in &v2 {
    println!("{}", num);
}

v2.swap(0, 1); // v[0], v[1] = v[1], v[0]

let v3 = Vec::with_capacity(10); // Вектор с предопределённой ёмкостью
```

### String / &str
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
    -  В Rust нельзя изменять строку (String) по индексу напрямую, потому что строки в Rust — это UTF-8, и символ может занимать более одного байта, а значит, “индекс” не всегда указывает на целый символ.

```rust
fn main() {
    let mut s = String::from("Hello");
    s.push_str(", world!"); // Можно изменять строку
    println!("{}", s);
}
```

### Slice
В языке программирования Rust срез (slice) — это представление непрерывного участка данных в коллекции, например, массива или вектора. Срези позволяют работать с подмножеством данных без необходимости копировать эти данные, что делает их очень эффективными.

Срез в Rust **не хранит данные** сам по себе, а лишь предоставляет доступ к части существующих данных. Это может быть полезно, например, для работы с массивами, строками или векторами:

```rust
struct Slice<'a, T> {
    ptr: *const T, // Указатель на первый элемент среза
    len: usize,    // Длина среза
}
```

#### Примеры

```rust
let arr = [1, 2, 3, 4, 5];    // type: [i32; 5]
let slice = &arr[1..4]; // Срез от индекса 1 до индекса 4 (не включая 4)
println!("{:?}", slice); // Выведет: [2, 3, 4]
```

```rust
let vec = vec![10, 20, 30, 40];
let slice = &vec[1..3]; // Срез от индекса 1 до индекса 3 (не включая 3)
println!("{:?}", slice); // Выведет: [20, 30]
```

```
let s = String::from("Hello, world!");
let slice = &s[0..5]; // Срез от индекса 0 до 5 (не включая 5)
println!("{}", slice); // Выведет: Hello
```

Срезы имеют следующие характеристики:
- Доступ по индексу: Срези предоставляют доступ к данным по индексу.
- **Невозможность изменения**: Срези предоставляют доступ только для чтения, если они не связаны с изменяемыми данными (например, с изменяемыми векторами или строками).
- Размер: Срези не хранят длину, но у них есть свойство, которое позволяет узнать длину через метод .len().


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


## Variable shadowing

`Маскирование(variable shadowing)` — это когда новое значение присваивается переменной с тем же именем, затирая её старое значение, но при этом не создавая нового экземпляра переменной. Это отличается от мутабельных переменных, где нужно использовать mut.

```rust
fn main() {
    let x = 1; // x = 1
    let x = 2; // x = 2 (маскируем предыдущее значение)
    let x = 3; // x = 3 (маскируем предыдущее значение)
    println!("{}", x); // 3
}
```

- Первая строка создаёт переменную x со значением 1.
- Во второй строке создаётся новая переменная с тем же именем x, но с другим значением 2. Предыдущее значение 1 больше не доступно.
- В третьей строке снова создаётся новая переменная x с значением 3, которая маскирует предыдущие.

Маскирование полезно, потому что:
1.	Переменная может быть переопределена новым значением без необходимости использовать mut. Это даёт вам возможность изменять значение переменной, сохраняя тот же идентификатор.
2.	Маскирование используется для изменения типа переменной:
3. Вы можете объявить одну переменную, а затем переопределить её тип. Например, сначала можно присвоить строку, а затем число:
```rust
let x = "Hello";
let x = x.len(); // x теперь число
println!("{}", x); // 5
```
4.	Это позволяет улучшить читаемость кода, так как вы не обязаны придумывать новые имена для каждой переменной, особенно если значение переменной изменяется в пределах одного контекста.

> Важно! На stack создается новая переменная при variable shadowing (в случае с динамическими типа - на heap):
> ```rust
> let x: i32 = 1;
> let x_address = &x as *const i32;
> println!("{:?}", x_address);    // 0x16b40eaa4
> let x = 2;
> let x_address = &x as *const i32;
> println!("{:?}", x_address);    // 0x16b40eb04
> ```

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

## if

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

# Ownership

> Владение применяется к:
> - String, Vec<T>, Box<T> — динамические структуры (heap)
> - Кастомные структуры (struct) и перечисления (enum), содержащие String, Vec, Box

> Владение НЕ применяется к:
> - Простым числам (i32, f64) — они копируются (Copy)
> - Булевым значениям (bool)
> - Массивам фиксированной длины [i32; 3]
> - Кортежам с Copy-типами ((i32, bool))
> - Ссылкам (&T, &mut T)


**Ownership** (владение) — это ключевая концепция Rust, которая позволяет управлять памятью без сборщика мусора (GC).

1. У каждой переменной есть единственный владелец.
2. При передаче переменной её владение передаётся (move).
3. Когда владелец выходит из области видимости — память освобождается.

## Примеры владения

```rust
fn main() {
    let s1 = String::from("Hello");
    let s2 = s1;  // s1 передаёт владение s2 (move)

    // println!("{}", s1);  Ошибка! s1 больше не владеет строкой
    println!("{}", s2);  //  Работает
}
```

### Клонирование (Clone)

Чтобы оставить оригинал доступным, используем .clone():

```rust
fn main() {
    let s1 = String::from("Hello");
    let s2 = s1.clone(); // Полное копирование данных

    println!("{}", s1); // Работает, т.к. s1 не потерял владение
}
```

### Передача во владение (Move)

Когда передаём переменную в функцию, её владение передаётся:

```rust
fn take_ownership(s: String) {
    println!("{}", s);
} // Здесь s удаляется, т.к. выходит из области видимости

fn main() {
    let s = String::from("Rust");
    take_ownership(s);
    
    // println!("{}", s);  Ошибка! s больше не существует
}
```

### Передача по ссылке (Borrowing)

Чтобы не терять владение, используем ссылки & (Ссылки не изменяют владение):
```rust
fn borrow_string(s: &String) {
    println!("{}", s);
}

fn main() {
    let s = String::from("Hello");
    borrow_string(&s); // Передаём ссылку, а не владение
    println!("{}", s); // s всё ещё доступен
}
```

### Изменяемые ссылки (Mutable Borrowing)
```rust
fn change_string(s: &mut String) {
    s.push_str(", world!");
}

fn main() {
    let mut s = String::from("Hello");
    change_string(&mut s); // Передаём изменяемую ссылку
    println!("{}", s); // "Hello, world!"
}
```

**Правило**: В один момент времени может быть только одна &mut ссылка или любое количество & ссылок, но не одновременно!

### Возврат владения

Чтобы вернуть значение после функции:

```rust
fn return_ownership(s: String) -> String {
    s  // Возвращаем владение
}

fn main() {
    let s = String::from("Hello");
    let s = return_ownership(s);
    println!("{}", s); //  Работает
}
```

## Итого
- Rust не использует GC, а управляет памятью через владение и заимствование.
- Передача переменной в функцию или присваивание перемещает (move) её.
- Используйте ссылки &, если хотите передать данные без потери владения.
- Используйте &mut, если хотите изменить данные без передачи владения.

# Struct, impl, enum
## Struct

```rust
struct Car {
    name: String,
    max_gas: f64,
    current_gas: f64,
    gas_consumption: f64,
    speed: f64,
}

impl Car {
    fn new(name: String, max_gas: f64, current_gas: f64, gas_consumption: f64, speed: f64) -> Self {
        Self {
            name: name,
            max_gas: max_gas,
            current_gas: current_gas,
            gas_consumption: gas_consumption,
            speed: speed,
        }
    }

    // or shortcutted form (will use input arguments)
    fn new(name: String, max_gas: f64, current_gas: f64, gas_consumption: f64) -> Self {
        Self {
            name,
            max_gas,
            current_gas,
            gas_consumption,
            speed,
        }
    }


    fn drive(&mut self, distance: f64) {
        let gas_spent: f64 = self.gas_consumption * distance / 100.0;
        self.current_gas -= gas_spent;
    }
    
    fn km_left(&self) -> f64 {
        return self.current_gas / self.gas_consumption * 100.0;
    }

    fn is_faster(&self, other: &Car) -> bool {
        return self.speed > other.field;
    }
}

fn main() {
    let mut car: Car = Car::new(String::from("Ford"), 55.0, 55.0, 10.0, 100.0);
    let distance: f64 = 400.0;

    car.drive(distance);

    // redefine current_gas field, other fields will be derived from car
    let mut car2: Car = Car{
        current_gas: 10.0,
        ..car
    };

    println!("gas left: {}, km left: {}", car.current_gas, car.km_left());
}
```

Для краткости, вы можете создавать структуры, которые используются точно так же как кортежи (tuple):

```rust
struct Location(i32, i32);

fn main() {
    // This is still a struct on a stack
    let loc = Location(42, 32);
    println!("{}, {}", loc.0, loc.1);
}
```


## Enums
```rust
enum Species {
    Crab, // 0
    Octopus, // 1
    Fish, // ...
    Clam
}

enum Species {
    Crab = 2,     // 2
    Octopus,         // 3
    Fish = 10,     // 10    
    Clam            // 11
}

let spec_type: Species = Species::Crab;
```

## Более сложные Enum
```rust
#[derive(Debug)]
enum Status {
    Created{amount: i32},
    Paid,
    Sent,
    Disputed(String)
}

let status_0: Status = Status::Created{amount: 22};
let status_1: Status = Status::Disputed(String::from("broken"));

println!("{status_0:#?}\n{status_1:#?}");

// output:

// Disputed(
//     "broken",
// )
// Created {
//     amount: 22,
// }

```

## Impl для Enum
```rust
#[derive(Debug)]
enum Status {
    Created{amount: i32},
    Disputed(String)
}

impl Status {
    fn info(&self) {
        // необходимо покрыть все статусы!!!
        match self {
            Self::Created{amount} => println!("{amount}"),
            Self::Disputed(reason) => println!("Hello {reason}"),
        }
    }
}

fn main() {
    let status_0: Status = Status::Disputed(String::from("broken"));
    let status_1: Status = Status::Created{amount: 22};

    status_0.info();
    status_1.info();
}

```

# Option, Some, None

В Rust `None` — это отсутствие значения в `Option<T>`. Это аналог null, но безопаснее, потому что Rust заставляет явно обрабатывать `None`.

## Пример
`None` — это часть `Option<T>`, который может быть либо `Some(value)`, либо `None`.

```rust
fn main() {
    let no_value: Option<i32> = None;
    println!("{:?}", no_value); // Выведет "None"
}
```

## Проверка None с match

Rust не позволяет напрямую разыменовывать None. Нужно использовать match:

```rust
fn check_value(value: Option<i32>) {
    match value {
        Some(n) => println!("Значение: {}", n),
        None => println!("Нет значения"),
    }
}

fn main() {
    let some_number = Some(42);
    let no_number: Option<i32> = None;

    check_value(some_number);
    check_value(no_number);
}
```

## Упрощённый способ (if let)
```rust
fn main() {
    let maybe_number = None;

    if let Some(n) = maybe_number {
        println!("Число: {}", n);
    } else {
        println!("Это None!");
    }
}
```

## Значение по умолчанию (unwrap_or)
Если Option<T> может быть None, можно задать значение по умолчанию:
```rust
fn main() {
    let value: Option<i32> = None;
    let result = value.unwrap_or(100);
    println!("Результат: {}", result);    // Результат: 100
}
```

## Ошибка при None: unwrap() и expect()
Если вызвать unwrap() на None, произойдёт паника:
```rust
fn main() {
    let value: Option<i32> = None;
    println!("{}", value.unwrap()); // Ошибка! thread 'main' panicked at 'called `Option::unwrap()` on a `None` value'
}
```

Поэтому можно либо проверять значение через match, либо использовать unwrap_or(value), которое в случае если Option == None вернет значение value.


# Traits
## Что такое
В Rust `trait` – это механизм, который определяет обязательные методы для типов, которые его реализуют. Это аналог интерфейсов в других языках программирования (например, Go), но с более мощными возможностями, такими как умолчательные реализации и динамическое диспетчерирование.

```rust
// Этот трейт требует, чтобы тип, который его реализует, определял метод speak().
trait Speaker {
    fn speak(&self);
}

struct Dog;
struct Cat;

impl Speaker for Dog {
    fn speak(&self) {
        println!("Im dog");
    }
}


impl Speaker for Cat {
    fn speak(&self) {
        println!("Im cat");
    }
}

fn make_noise(speaker: & impl Speaker) {
    speaker.speak();
}

fn main() {
    let d: Dog = Dog{};
    let c: Cat = Cat{};

    make_noise(&d); // Im cat
    make_noise(&c); // Im dog

    // or
    d.speak(); // Im dog
    c.speak(); // Im cat
}
```

## Дефолтная реализация методов

Трейты могут содержать умолчательные реализации, которые можно переопределить:

```rust
trait Greet {
    fn hello(&self) {
        println!("Hello, world!");
    }
}

struct Human;
impl Greet for Human {} // Использует стандартную реализацию

fn main() {
    let h = Human;
    h.hello(); // Hello, world!
}
```


# Generic Types
В Rust можно использовать общие типы (`Generics`) для создания функций, структур, перечислений или типов, которые могут работать с разными типами данных. Это позволяет писать общий, переиспользуемый код, который работает с любыми типами, при этом сохраняя безопасность типов на этапе компиляции.

Когда вы используете generics в функции, структуре или перечислении, rustc генерирует код для каждого конкретного типа, с которым эта функция или структура будет вызвана или использована. Этот процесс называется `мономорфизацией` (monomorphization).

## Generic функции
```rust
fn print_value<T>(value: T) {
    println!("{:?}", value);
}

// В print_value(42) компилятор автоматически понимает, что T — это i32, и проверяет тип.
fn main() {
    print_value(42);          // i32
    print_value("Hello");     // &str
    print_value(3.14);        // f64
}
```

## Генерики в структурах
```rust
struct Point<T> {
    x: T,
    y: T,
}

fn main() {
    let int_point = Point { x: 1, y: 2 }; // Point<i32>
    let float_point = Point { x: 1.0, y: 2.0 }; // Point<f64>
}
```

## Генерики в перечислениях
```rust
enum Option<T> {
    Some(T),
    None,
}

fn main() {
    let some_number = Option::Some(42); // Option<i32>
    let no_value: Option<i32> = Option::None; // Option<i32>
}
```

## Ограничения на типы с помощью trait
```rust
use std::fmt::Debug;

// T: Debug — это ограничение на тип T, которое требует, чтобы тип T реализовывал трейt Debug.
fn print_debug<T: Debug>(value: T) {
    println!("{:?}", value);
}

fn main() {
    print_debug(42);       // i32, реализует Debug
    print_debug("Hello");  // &str, реализует Debug
    // print_debug([1, 2, 3]); // Массив не реализует Debug по умолчанию, приведёт к ошибке
}
```

## Обобщённые методы для структуры
struct Container<T> {
    value: T,
}

impl<T> Container<T> {
    fn new(value: T) -> Self {
        Container { value }
    }

    fn get_value(&self) -> &T {
        &self.value
    }
}

fn main() {
    let container = Container::new(42);
    println!("{}", container.get_value());
}

## Множественные типы в генераках
```rust
struct Pair<T, U> {
    first: T,
    second: U,
}

fn main() {
    let pair = Pair { first: 42, second: "Hello" };
}
```

# Указатели
