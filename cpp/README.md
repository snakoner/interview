## Done

1. Типы данных и приведение типов.md
2. Векторы и строки.md
3. Составные типы данных.md
4. Ссылки, указатели, константность.md
5. Функции, лямбда-функции.md
6. Шаблоны.md
7. Последовательные контейнеры.md
8. Ассоциативные контейнеры.md
9. Алгоритмы на контейнерах.md
10. Адаптеры и представления.md
11. Классы.md
12. Жизненный цикл объектов.md
13. Наследование и полиморфизм.md
14. Исключения.md

## TODO

15. Умные указатели.md [todo: weak_ptr]


## questions
1. В чем отличие конструктора копирования от оператора присваивания?
>   Конструктор копирования создаёт новый объект, а оператор присваивания модифицирует уже существующий

```cpp
A a;
A aa = a; // конструктор копирования

B b;
B bb;
b = bb; // оператор присваивания
```

2. Отличие `delete` от `delete[]`?
> Оператор `delete` освобождает память и вызывает деструктор для одного объекта, созданного с помощью `new`.
> Оператор `delete[]` освобождает память и вызывает деструкторы для массива объектов, созданных с помощью `new[]`.
> Если использовать `delete[]` после `new` или `delete` после `new[]`, то undefined behaviour.

3. Отличие static_cast от dynamic_cast?
   
static_cast можно использовать для приведенеия от Base к Derived, так и от Derived к Base\
dynamic_cast можно использовать для приведенеия от Derived к Base, но использовать от Base к Derived можно только тогда, когда Base является полиморфным (имеет хотя бы одну виртуальную функцию)\

```cpp
class Base {
public:
    void hello() {
        std::cout << "hello" << std::endl;
    }
};

class Derived : public Base {
    
};

int main() {
    Derived d;
    Base *b = static_cast<Base *>(&d);

    static_cast<Derived *>(b);      // ok always
    static_cast<Base *>(&d);        // ok always

    dynamic_cast<Base *>(&d);       // ok always
    dynamic_cast<Derived *>(b);     // ok only if Base is polymorphic

    return 0;
}
```

4. Шаблоны нужно объявлять в header файлах, так как иначе компилятор не сможет инстанцировать нужный тип.

5. При передаче указателя внутрь функции нельзя изменить переданный указатель, чтоб он указывал на другую переменную - причина: передается копия указателя.

```cpp
int a = 1;
int b = 2;

void func(int *ptr) {
    ptr = &b;
    std::cout << *ptr << std::endl;
}

int main() {
    int *x = &a;
    std::cout << *x << std::endl;
    func(x);
    std::cout << *x << std::endl;
}

// > 1
// > 2
// > 1
```

6. Функтор - объект класса, для которого определен operator(). В отличие от функций, они могут сохранять некоторое состояние. 

7. Пример кода:

```cpp
class Data {
public:
   Data() {
      throw std::out_of_range("test exception");
   }
};

int main () {
   try {
      Data *data = new Data;
      delete data; // не вызовется, так как исключение в конструкторе
   } catch(Exception& e) {
      std::cout << e.what() << std::endl;
   }
}
```

Вопрос: будет ли утечка памяти? \
Ответ: нет, так как new гарантирует атомарность: (malloc + constructor). В случае, если исключение произошло в констукторе, то память будет освобождена.


8. Что такое union?

Union нужен когда в машине нужно более комфортно хранить данные. Union гарантирует, что юнион зарезервирована память под самый большой элемент.

```cpp
union Rgb {
    uint32_t value;
    struct {
        uint8_t r;
        uint8_t g;
        uint8_t b;
    };
};

Rgb rgb; // размер union будет 32 бита

rgb.value = 0x112233; // пишем в область на стеке это значение

printf("r = %x g = %x b = %x\n", rgb.r, rgb.g, rgb.b); // 0x11 0x22 0x33

```

9. Copy-elission vs tmp objects:
Рассмотрим код:
```cpp
class A {
private: 
    int x;
public:
    A(int x) : x(x) {
        std::cout << "int" << std::endl;
    }
    A(const A &a) {
        std::cout << "const &" << std::endl;
    }
    A(A&& a) {
        std::cout << "&&" << std::endl;
    }
};

int main() {
    A a(A(1));   // "int"
}
```

Здесь сработает copy-elission, конструктор перемещения не будет вызван.
