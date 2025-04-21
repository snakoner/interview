# Common questions
## 1. Создаётся ли копия при возврате Vec<i32> из функции?

Нет, копия не создаётся. Вектор (Vec<T>) передаётся по перемещению (move semantics), а не копируется. Это означает, что владелец данных изменяется без создания дубликата.

```rust
fn create_vector() -> Vec<i32> {
    let v = vec![1, 2, 3]; // Создаём вектор
    v // Возвращаем вектор (перемещение, без копирования)
}

fn main() {
    let v1 = create_vector(); // v "переезжает" сюда
    println!("{:?}", v1); // [1, 2, 3]
}
```

## 2. Как получить адрес переменной?
```rust
fn main() {
    let x: i32 = 1;
    let p_x = &x as *const i32;
    println!("{:p}", p_x);
}    
```

```rust
fn main() {
    let mut x = 42;
    let x_address = &mut x as *mut i32; // Получаем мутабельный указатель на переменную x

    println!("Address of x: {:p}", x_address); // Выводим адрес в шестнадцатеричном формате
}
```
## 3. ":?", ":#?"

В Rust `:?` и `:#?` используются в формате `println!` и других макросах форматирования для отладки. Они связаны с Debug-форматированием. \
Используется для вывода значений, которые реализуют `std::fmt::Debug`.

- :? — Дебажный вывод (Debug formatting):
```rust
#[derive(Debug)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p = Point { x: 10, y: 20 };
    println!("{:?}", p);  // Выведет: Point { x: 10, y: 20 }
}
```

- :#? — Красивый (pretty) Debug:
```rust
#[derive(Debug)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p = Point { x: 10, y: 20 };
    println!("{:#?}", p);
    /* выведет
    Point {
        x: 10,
        y: 20,
    }
    */
}
```

## 4. Срезы
```rust
    let mut vec = vec![1,2,3,4];
    let mut slice = &mut vec[0..2]; // изменяемый срез, который указывает на те же данные, что и vec

    slice[0] = 100;

    println!("{:?}", slice); // [100, 2]
    println!("{:?}", vec); // [100, 2, 3, 4]

```

## Почему не нужен GC?
- Rust отслеживает владельца на этапе компиляции.
- Как только владелец умирает, компилятор вставляет drop().
- Никаких “паузы на сборку мусора”, всё происходит сразу и точно.

## 5. Пример с Box
```rust
struct Test {
    value: Option<Box<i32>>,
}

fn main() {
    let mut test = Test{
        value: Some(Box::new(1)),
    };
    // Вопроc: когда очистится память под 1?
    println!("{}", test.value.unwrap()); // move, здесь передается владение функции(макросу)
    // println!("{}", test.value.unwrap()); // !!!! error: value used here after move
    test.value = Some(Box::new(2)); // test.value - владелец значения 2 в heap
    println!("{}", test.value.unwrap());
}
```

## 6. Пример с list
```rust
    let mut list: Option<Box<ListNode>> = Some(Box::new(ListNode::new(1)));
    if let Some(mut node) = list { // moved to node here
        if node.next.is_none() {
            node.next = Some(Box::new(ListNode::new(2)));
        }
    }

    println!("{:?}", list); // error: value borrowed here after partial move
```

Если мы хотим, чтобы владение не было передано в node, нужно сделать ref mut:

```rust
    let mut list: Option<Box<ListNode>> = Some(Box::new(ListNode::new(1)));
    if let Some(ref mut node) = list { // moved to node here
        if node.next.is_none() {
            node.next = Some(Box::new(ListNode::new(2)));
        }
    }

    println!("{:?}", list); // Ok
```

## 7. &mut 
Изменяемые ссылки имеют одно большое ограничение: если у вас есть изменяемая ссылка на значение, у вас не может быть других ссылок на это же значение. Код, который пытается создать две изменяемые ссылки на s, завершится ошибкой:

```rust
let mut s = String::from("hello");
let ref_s1 = &mut s;
let ref_s2 = &mut s; // error
```
