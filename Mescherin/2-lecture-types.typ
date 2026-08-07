= Типы, выражения и операторы

== Статическая типизация, compile-time и runtime

Есть `static` и `dynamic`, `compile-time` и `runtime`.

- `compile-time` — время компиляции: проверка кода, поиск объявлений, выбор перегрузок, определение типов выражений, сборка исполняемого файла.
- `runtime` — время выполнения уже готовой программы.

Все переменные в C++ имеют статическую типизацию: тип определяется в момент compile-time, и изменить это после компиляции невозможно.

```cpp
#include <iostream>

int main() {
    int x = 5;

    // x = "abc"; // Error: cannot assign const char[4] to int.

    std::cout << x << std::endl;
}
```

== Типы в C++

*1. Integral types (целочисленные):*

+ `int` (по стандарту минимум 2 байта, обычно 4 байта) `[-2^31; 2^31 - 1]`
+ `long long` (по стандарту хотя бы 8 байт)
+ `short` (обычно 2 байта)
+ `long` (по стандарту минимум 4 байта)
+ `char` (1 байт)

Ещё можно использовать префикс `unsigned`. Сам по себе `unsigned` по умолчанию — `unsigned int`. Есть типы с фиксированным количеством бит:

+ `int8_t`
+ `int16_t`

И их unsigned-аналоги:

+ `uint32_t`

Ещё есть тип, способный проиндексировать все ячейки памяти:

+ `size_t`
+ `ssize_t` (знаковый аналог)

Есть ещё логические переменные:

+ `bool` (1 байт)

*2.* `void`

*3. Числа с плавающей точкой (floating point numbers):*

+ `float` (32 бита)
+ `double` (64 бита)
+ `long double` (80–128 бит на x86; платформозависимо — на ARM64/macOS совпадает с `double` и занимает 8 байт)

*4.* C-style строка

*5.* `std::string` (не базовый тип, а тип стандартной библиотеки, однако очень популярен)

*6.* `std::vector`

Размеры базовых типов:

```cpp
#include <iostream>

int main() {
    std::cout << "sizeof(short) = " << sizeof(short) << std::endl;             // 2
    std::cout << "sizeof(int) = " << sizeof(int) << std::endl;                 // 4
    std::cout << "sizeof(long) = " << sizeof(long) << std::endl;               // 8
    std::cout << "sizeof(long long) = " << sizeof(long long) << std::endl;     // 8
    std::cout << "sizeof(char) = " << sizeof(char) << std::endl;               // 1
    std::cout << "sizeof(bool) = " << sizeof(bool) << std::endl;               // 1
    std::cout << "sizeof(float) = " << sizeof(float) << std::endl;             // 4
    std::cout << "sizeof(double) = " << sizeof(double) << std::endl;           // 8
    std::cout << "sizeof(long double) = " << sizeof(long double) << std::endl; // 8
}
```

== Знаковые и беззнаковые

При смешивании `int` и `unsigned` знаковый операнд обычно приводится к беззнаковому:

```cpp
#include <iostream>

int main() {
    int signed_value = -1;
    unsigned unsigned_value = 1u;

    std::cout << signed_value << std::endl;   // -1
    std::cout << unsigned_value << std::endl; // 1

    // int + unsigned usually converts int to unsigned.
    std::cout << (0u - 1) << std::endl; // Usually 4294967295 for 32-bit unsigned.
}
```

Типы фиксированной ширины из `<cstdint>`:

```cpp
#include <cstdint>
#include <iostream>

int main() {
    std::int8_t a = 100;
    std::int32_t b = -1'000'000;
    std::uint64_t c = 1ull << 40;

    // int8_t is often an alias for signed char, so cout may print it as a character.
    std::cout << static_cast<int>(a) << std::endl; // 100 (без каста напечаталось бы 'd')
    std::cout << b << std::endl;                   // -1000000
    std::cout << c << std::endl;                   // 1099511627776
}
```

`size_t` — тип результата `sizeof` и размеров контейнеров:

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> v = {1, 2, 3};

    std::size_t n = v.size();

    std::cout << n << std::endl;          // 3
    std::cout << sizeof(42) << std::endl; // 4
}
```

== Литералы и суффиксы

Литерал обозначает константу фиксированного типа:

```cpp
1      // int
3.14   // double
true   // bool
"abc"  // const char [4]
'a'    // char
```

Плюс суффиксы:

```cpp
1u
1ull
1ll
1z
1.f    // float
"abc"s // string, но нужен std::literals::string_literals::operator""s
```

Какой именно тип у литерала с плавающей точкой, видно по разрешению перегрузки:

```cpp
#include <iostream>

void f(float) {
    std::cout << "float" << std::endl;
}

void f(double) {
    std::cout << "double" << std::endl;
}

void f(long double) {
    std::cout << "long double" << std::endl;
}

int main() {
    f(3.14);   // double literal
    f(3.14f);  // float literal
    f(3.14L);  // long double literal
}
```

Строковый литерал и `std::string`-литерал — разные типы. У `"abc"` размер 4 из-за завершающего нуля:

```cpp
#include <iostream>
#include <string>
#include <typeinfo>

int main() {
    using namespace std::string_literals;

    std::cout << sizeof("abc") << std::endl; // 4, because of the terminating '\0'.

    auto c_string = "abc";
    auto cpp_string = "abc"s;

    std::cout << typeid(c_string).name() << std::endl;   // PKc — const char*
    std::cout << typeid(cpp_string).name() << std::endl; // ...basic_string... — std::string
}
```

```cpp
#include <iostream>
#include <string>

int main() {
    using namespace std::string_literals;

    std::cout << true << std::endl;          // 1
    std::cout << sizeof("abc") << std::endl; // 4
    std::cout << "abc"s.size() << std::endl; // 3
}
```

== Undefined behaviour

В C++ есть undefined behaviour (UB) — стандарт не устанавливает правил для такой ситуации, поведение не определено.

Чтение неинициализированной локальной переменной:

```cpp
#include <iostream>

int main() {
    int x;

    std::cout << x << std::endl; // UB: x was not initialized.
}
```

Знаковое переполнение:

```cpp
#include <iostream>
#include <limits>

int main() {
    int x = std::numeric_limits<int>::max();

    std::cout << x + 1 << std::endl; // UB for signed int. На практике -2147483648
}
```

А вот беззнаковое переполнение определено — по модулю `2^N`:

```cpp
#include <iostream>
#include <limits>

int main() {
    unsigned x = std::numeric_limits<unsigned>::max();

    std::cout << x << std::endl;     // 4294967295
    std::cout << x + 1 << std::endl; // 0 for ordinary unsigned int.
}
```

== Преобразования

Есть расширяющие и сужающие преобразования. Расширяющие более приоритетные: integer promotion и floating point promotion.

- `char + char = int`
- `int + unsigned = unsigned` (`0u - 1 = 4 000 000 000`)

Integer promotion — операнды меньше `int` подтягиваются до `int`:

```cpp
#include <iostream>
#include <typeinfo>

int main() {
    char first = 1;
    char second = 2;

    auto sum = first + second; // оба операнда char, но результат уже int

    std::cout << sum << std::endl;                // 3
    std::cout << typeid(sum).name() << std::endl; // Usually "i" for int.
}
```

Сужающие преобразования теряют данные. Обычная инициализация их допускает, а списковая — запрещает:

```cpp
#include <iostream>

int main() {
    double pi = 3.14;
    int x = pi; // Fractional part is discarded.

    std::cout << x << std::endl; // 3

    // int y{pi}; // Error: list-initialization rejects narrowing.
}
```

```text
error: type 'double' cannot be narrowed to 'int' in initializer list [-Wc++11-narrowing]
```

== Разрешение перегрузки

При выборе перегрузки расширение (promotion) предпочтительнее преобразования (conversion):

```cpp
#include <iostream>

void f(int) {
    std::cout << "int" << std::endl;
}

void f(double) {
    std::cout << "double" << std::endl;
}

int main() {
    f(1);    // Exact match: int.
    f(1.0);  // Exact match: double.
    f(1.0f); // float -> double promotion is better than float -> int conversion.
}
```

Если оба кандидата требуют равноценного преобразования, вызов неоднозначен:

```cpp
#include <iostream>

void g(int) {
    std::cout << "int" << std::endl;
}

void g(float) {
    std::cout << "float" << std::endl;
}

int main() {
    // g(1.0); // Error: double -> int and double -> float are both conversions.
}
```

```text
error: call to 'g' is ambiguous
```

== Выражения и операторы

Выражение-инструкция вычисляется, а результат отбрасывается:

```cpp
#include <iostream>

int main() {
    int x = 1;
    int y = 2;

    x + y; // Expression statement: the result is computed and discarded.

    std::cout << x + y << std::endl; // 3
}
```

Arithmetic (integer) operators: `+ - / % * & | ^ << >> ~ < > <= >= == != <=>`. Logical operators (bool): `|| && !`.

```cpp
#include <iostream>

int main() {
    int x = 10;
    int y = 3;

    std::cout << x + y << std::endl; // 13
    std::cout << x - y << std::endl; // 7
    std::cout << x * y << std::endl; // 30
    std::cout << x / y << std::endl; // Integer division. 3
    std::cout << x % y << std::endl; // Remainder. 1

    std::cout << (x & y) << std::endl;  // 2
    std::cout << (x | y) << std::endl;  // 11
    std::cout << (x ^ y) << std::endl;  // 9
    std::cout << (x << 1) << std::endl; // 20
    std::cout << (x >> 1) << std::endl; // 5
}
```

Логические операторы возвращают `bool`, побитовые — целое число:

```cpp
#include <iostream>

int main() {
    int x = 2; // binary 10
    int y = 1; // binary 01

    std::cout << (x && y) << std::endl; // true -> 1
    std::cout << (x & y) << std::endl;  // 0
}
```

Унарные операторы:

```cpp
#include <iostream>

int main() {
    int x = 5;
    bool ok = false;
    unsigned mask = 0b1010u;

    std::cout << +x << std::endl;    // 5
    std::cout << -x << std::endl;    // -5
    std::cout << !ok << std::endl;   // 1
    std::cout << ~mask << std::endl; // 4294967285
}
```

Префиксный и постфиксный инкремент:

```cpp
#include <iostream>

int main() {
    int x = 1;

    std::cout << ++x << std::endl; // First increments, then returns: 2.
    std::cout << x++ << std::endl; // First returns 2, then increments.
    std::cout << x << std::endl;   // 3.

    std::cout << --x << std::endl; // 2.
    std::cout << x-- << std::endl; // 2.
    std::cout << x << std::endl;   // 1.
}
```

== Тернарный оператор

```cpp
#include <iostream>

int main() {
    int x = 10;
    int y = 20;

    int mx = x > y ? x : y;

    std::cout << mx << std::endl;                             // 20
    std::cout << (mx % 2 == 0 ? "even" : "odd") << std::endl; // even

    auto value = true ? 1 : 2.5; // double, because branches need a common type.
    std::cout << value << std::endl; // 1
}
```

Вычисляется только одна ветка:

```cpp
#include <iostream>

int main() {
    int evaluated = 1;
    int skipped = 2;

    int result = true ? ++evaluated : ++skipped;

    std::cout << evaluated << std::endl; // 2
    std::cout << skipped << std::endl;   // 2, because ++skipped was not evaluated.
    std::cout << result << std::endl;    // 2
}
```

Если обе ветки — `lvalue` одного типа, всё выражение является `lvalue`:

```cpp
#include <iostream>

int main() {
    int chosen = 1;
    int untouched = 2;
    int value = 3;

    (true ? chosen : untouched) = value; // присваивание уходит в выбранную ветку

    std::cout << chosen << std::endl;    // 3
    std::cout << untouched << std::endl; // 2
}
```

А если хотя бы одна ветка — `rvalue`, присваивать всему выражению нельзя:

```cpp
#include <iostream>

int main() {
    int lvalue_branch = 1;
    int rvalue_branch = 2;
    int value = 3;

    // (true ? ++lvalue_branch : rvalue_branch++) = value;
    // Error: rvalue_branch++ returns a temporary old value.
}
```

== Оператор запятая

Вычисляет левую часть, затем правую, и возвращает правую:

```cpp
#include <iostream>

int main() {
    int x = 1;
    int y = (x += 2, x *= 3);

    std::cout << x << std::endl; // 9
    std::cout << y << std::endl; // 9
}
```

== `sizeof`

`sizeof` вычисляется на этапе компиляции и не вычисляет свой операнд:

```cpp
#include <iostream>

int main() {
    int x = 0;

    std::cout << sizeof(int) << std::endl;   // 4
    std::cout << sizeof(2 + 2) << std::endl; // 4

    std::cout << sizeof(x++) << std::endl; // x++ is not evaluated here. 4
    std::cout << x << std::endl;           // 0
}
```

== Приоритет и ассоциативность

```cpp
#include <iostream>

int main() {
    std::cout << 2 + 3 * 4 << std::endl;   // 14
    std::cout << (2 + 3) * 4 << std::endl; // 20

    std::cout << 10 - 3 - 2 << std::endl; // (10 - 3) - 2 == 5

    int a = 0;
    int b = 0;
    int c = 7;

    a = b = c; // a = (b = c)

    std::cout << a << " " << b << " " << c << std::endl; // 7 7 7
}
```

Приоритета мало: разобранное выражение должно быть ещё и семантически корректным.

```cpp
#include <iostream>

int main() {
    int a = 1;

    // ++a++ is parsed as ++(a++), because postfix ++ has higher precedence.
    // It still does not compile: a++ returns a temporary old value, and prefix ++
    // needs a modifiable lvalue.
    // ++a++;
}
```

```text
error: expression is not assignable
```

== Ленивые вычисления

Правая часть `&&` не вычисляется, если левая уже даёт ответ:

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> v = {1, 2, 3};

    if (v.size() > 4 && v[4] == 10) {
        std::cout << "The fifth element is 10" << std::endl;
    } else {
        std::cout << "Safe: v[4] was not evaluated" << std::endl;
    }
}
```

То же самое для `||`:

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> v;

    if (v.empty() || v[0] != 0) {
        std::cout << "Safe: v[0] was not evaluated" << std::endl;
    }
}
```

== `lvalue` и `rvalue`

Присваивание возвращает свой левый операнд как `lvalue`:

```cpp
#include <iostream>

int main() {
    int x = 0;
    int y = 5;

    std::cout << (x = y) << std::endl; // Prints 5.

    (x = y) = 10; // The result of x = y is x itself.

    std::cout << x << std::endl; // Prints 10.
}
```

Составные присваивания тоже возвращают `lvalue`:

```cpp
#include <iostream>

int main() {
    int x = 1;
    int y = 2;

    (x += y) += 5;

    std::cout << x << std::endl; // 8
}
```

Интуиция: `lvalue` — то, чему можно присваивать, `rvalue` — временное значение:

```cpp
#include <iostream>

int main() {
    int x = 1;

    x = 2; // ok: x is an lvalue.

    // (x + 1) = 3; // Error: x + 1 is a temporary value.
    // 5 = x;       // Error: literal 5 is not assignable.
}
```

```text
error: expression is not assignable
```
