= Основы: история, объявления и пространства имён

== Немного истории

Язык C++ придумал датский программист Бьёрн Страуструп (Bjarne Stroustrup) в начале 1980-х. Он вырос из языка C: C был процедурным языком с переменными, функциями, указателями и работой с сырой памятью, но без ООП, шаблонов, классов и удобных контейнеров стандартной библиотеки. C++ добавил огромное число возможностей, при этом почти сохранив обратную совместимость с C (строго говоря, не любая корректная C-программа корректна как C++, но на практике почти любая). Во многом C++ — надмножество C.

У C++ есть стандарты — формальные документы (сейчас порядка 1700 страниц), описывающие все возможности языка. Первым был C++98, затем:

- C++03
- *C++11*
- C++14
- *C++17*
- *C++20*
- C++23
- *C++26*

Начиная с 2011 года стандарты выходят каждые 3 года (жирным отмечены внёсшие значительные изменения; переход C++03 → C++11 — самый радикальный, граница между «классическим» и современным C++). Между выходом стандарта и полной поддержкой его компиляторами проходит около 3 лет, а до повсеместного использования — ещё несколько; поэтому «в среднем по индустрии» пишут с отставанием (условно на уровне C++17).

Новые версии принимает комитет по стандартизации: сам Страуструп, представители многих стран (в России — Антон Полухин из Яндекса) и ведущих IT-компаний. C++ широко применяется там, где важна эффективность: значительные части Яндекса и Google, Telegram, операционные системы, игры, биржи (в т.ч. Московская), Bitcoin.

C++ — компилируемый язык; популярные компиляторы — `g++` и `clang++`. Важно не путать версию языка со версией компилятора. Изучение C++ во многом похоже на изучение матанализа, линейной алгебры или физики — оно задаёт фундамент для дальнейших языков и технологий. Аналогия Ильи Мещерина при сравнении Python и C++:

#quote[Представьте, что вы пришли в ресторан. Официант принесёт вам меню. Однако если вы сами профессиональный повар, то простое меню вам не подойдёт. Вместо этого вам понадобится список ингредиентов, чистый лист бумаги и ручка, чтобы вы могли сами написать рецепт того, что хотите сегодня съесть.]

== Комментарии

```cpp
// однострочные комментарии пишутся так

/* Или
 * многострочные
 * комментарии
 */
```

== Статическая типизация

Типизация в C++ статическая: тип каждой переменной известен на этапе компиляции и не меняется во время выполнения. Если переменная объявлена как `int`, никаким способом нельзя заставить её сменить тип в runtime (подробнее о типах — в следующей лекции).

== `using namespace std` и `using`-объявления

Лучше не писать `using namespace std;` — это плохая практика: все имена стандартной библиотеки попадают в глобальную область видимости.

```cpp
#include <iostream>

int main() {
    int x = 5;
    std::cout << x << std::endl;
}
```

Чтобы подключить явно, можно делать так:

```cpp
#include <iostream>

using namespace std;

int main() {
    int x = 5;
    cout << x << endl;
}
```

Либо так — тогда `using` будет действовать только внутри scope'а `main`:

```cpp
#include <iostream>

int main() {
    using namespace std;

    int x = 5;
    cout << x << endl;
}
```

Ещё можно явно объявлять используемые имена. Такое объявление тоже работает только внутри scope'а `main`, и вводит именно *конкретное* имя:

```cpp
#include <iostream>

int main() {
    using std::cout; // введено только cout

    int x = 5;
    // cout << x << endl;   // std::endl не объявлен, программа не скомпилируется.
                            // Нужно было писать using std::cout, std::endl;

    cout << x << std::endl; // так всё заработает

    using std::endl;

    cout << x << endl;      // и так тоже
}
```

== Объявления, определения и области видимости

*Объявление* (declaration) вводит имя, *определение* (definition) вдобавок задаёт саму сущность. Для переменных это обычно одно и то же:

```cpp
int counter;            // declaration и definition
double pi = 3.14159265; // declaration и definition
```

Для функций объявление и определение разделены. Функцию нужно всегда хотя бы объявить до использования, но определение может идти уже после вызова:

```cpp
#include <iostream>

void print_next(int x); // declaration only, not definition

// declaration и definition
int get_one() {
    return 1;
}

int main() {
    std::cout << get_one() + 1 << std::endl; // 2
    print_next(1);                           // 2
}

// Определение идёт после использования — и это нормально
void print_next(int x) {
    std::cout << x + 1 << std::endl;
}
```

Если определения нет вовсе, программа не соберётся: до запуска дело не дойдёт, будет ошибка линковки.

*One Definition Rule* (ODR) — нельзя определять одну сущность несколько раз. Объявлять можно сколько угодно раз.

```cpp
int counter;
int counter; // Ещё раз написать так нельзя, потому что уже был definition counter'а
```

```text
error: redefinition of 'counter'
```

Функции могут отличаться по аргументам, но не по типу возвращаемого значения. Здесь имя обязано совпадать — в этом и суть перегрузки:

```cpp
int f() {
    return 1;
}

double f() { // ошибка
    return 1.1;
}
```

```text
error: functions that differ only in their return type cannot be overloaded
```

Разрешение перегрузки происходит *до* поиска определения. Если объявлена `f(int)`, а определена только `f(double)`, то вызов `f(3)` выберет `f(int)` — и упадёт на линковке:

```cpp
#include <iostream>

void f(int x);

int main() {
    f(3); // Ошибка линковки: выберет перегрузку для инта, а у неё нет определения.
          // Не будь void f(int x), всё бы заработало из-за расширяющего преобразования
}

void f(double x) {
    std::cout << x << std::endl;
}
```

```text
Undefined symbols for architecture arm64:
  "f(int)", referenced from: _main ...
```

А вот вызов `f(1.1)` точно совпадает с определённой `f(double)`, поэтому всё линкуется:

```cpp
#include <iostream>

void f(int x);

void f(double x) {
    std::cout << x << std::endl;
}

int main() {
    f(1.1); // 1.1
}
```

Локальное имя затеняет внешнее, а `::` обращается к глобальному. Имена здесь специально одинаковые — именно это и демонстрируется. Глобальные переменные инициализируются значением по умолчанию:

```cpp
#include <iostream>

int value;

int main() {
    // Здесь действует локальный scope main'а
    int value = 3;
    std::cout << value << std::endl;   // Выведет 3.
                                       // Локальное имя затмевает глобальное
    {
        int value = 5;
        std::cout << value << std::endl;   // Выведет 5.
                                           // "Более" локальное затмевает "менее" локальное
        std::cout << ::value << std::endl; // Обращение к глобальному value.
                                           // Выведет 0, так как глобальные переменные по
                                           // умолчанию инициализируются значением по default
    }
    std::cout << value << std::endl;   // Выведет 3.
}
```

Ловушка: инициализация переменной через саму себя во вложенном scope компилируется, но даёт UB — справа берётся уже объявленная внутренняя переменная, а не внешняя:

```cpp
#include <iostream>

int value = 1;

int main() {
    int value = 2;

    {
        int value = value + 3; // Скомпилируется, но поведение будет неопределено, так как
                               // value уже объявлена и используется она, а не внешняя
        std::cout << value << std::endl;
    }
}
```

== Пространства имён

Неймспейсы можно объявлять только в глобальной области видимости или внутри других неймспейсов. Обращение — через `::`:

```cpp
#include <iostream>

namespace lib {
    int value = 1;
}

int value = 3;

int main() {
    std::cout << lib::value << std::endl; // 1
    std::cout << value << std::endl;      // 3
}
```

Если глобального `value` нет, неквалифицированное имя не найдётся:

```cpp
#include <iostream>

namespace lib {
    int value = 1;
}

int main() {
    std::cout << lib::value << std::endl; // 1
    std::cout << value << std::endl;      // А вот так не скомпилируется: глобального value нет
}
```

```text
error: use of undeclared identifier 'value'; did you mean 'lib::value'?
```

=== `using`-объявление

`using lib::value` — это *using declaration*: оно вводит имя `value` в текущую область видимости.

```cpp
#include <iostream>

namespace lib {
    int value = 1;
}

int value = 3;

int main() {
    using lib::value;

    std::cout << lib::value << std::endl; // 1
    std::cout << value << std::endl;      // 1 — неквалифицированное имя теперь из lib
    std::cout << ::value << std::endl;    // 3
}
```

Именно потому, что имя *вводится* в scope, собственное локальное объявление с ним конфликтует:

```cpp
#include <iostream>

namespace lib {
    int value = 1;
}

int value = 3;

int main() {
    using lib::value;
    int value = 5; // А вот так уже нельзя — конфликт имён. Локальное объявление
                   // конфликтует с объявлением из namespace lib

    std::cout << lib::value << std::endl;
    std::cout << value << std::endl;
    std::cout << ::value << std::endl;

    // Разумеется, можно сделать using namespace lib;
}
```

```text
error: declaration conflicts with target of using declaration already in scope
```

=== `using`-директива

`using namespace lib` — это *using directive*, которая как бы говорит компилятору: «если не нашёл переменную в локальном скоупе, то разрешено ещё поискать в этом неймспейсе», то есть добавляет неймспейс в список проверки. Поэтому локальное имя не конфликтует, а просто приоритетнее:

```cpp
#include <iostream>

namespace lib {
    int value = 1;
    int other = 4;
}

int value = 3;

int main() {
    using namespace lib;

    int value = 2; // Не конфликт, так как локальное имя считается более приоритетным

    std::cout << value << std::endl;      // 2 — локальная
    std::cout << lib::value << std::endl; // 1
    std::cout << ::value << std::endl;    // 3
    std::cout << other << std::endl;      // 4 — найдено через директиву
    std::cout << later << std::endl;      // Не скомпилируется: later объявлен ниже по тексту
}

// Если объявлять после, то не заработает
namespace lib {
    int later = 5;
}
```

```text
error: use of undeclared identifier 'later'
```

Если же неймспейс с `later` объявлен *выше*, всё находится. Заодно видно, что внутри неймспейса допустимы только объявления:

```cpp
#include <iostream>

namespace lib {
    int value = 1;
    int other = 4;
}

namespace lib {
    int later = 5;
    // value = 2; // Так нельзя, потому что в неймспейсах можно только declaration, а это
                  // обычный statement
}

int value = 3;

int main() {
    using namespace lib;

    int value = 2; // Не конфликт, так как локальное имя считается более приоритетным

    std::cout << value << std::endl;      // 2
    std::cout << lib::value << std::endl; // 1
    std::cout << ::value << std::endl;    // 3
    std::cout << other << std::endl;      // 4
    std::cout << later << std::endl;      // 5
}
```

Но если имя находится сразу в двух местах — в глобальной области и в подключённом неймспейсе, — возникает неоднозначность:

```cpp
#include <iostream>

namespace lib {
    int value;
}

int value;

int main() {
    using namespace lib;
    std::cout << value << std::endl; // ошибка — ambigious
}
```

```text
error: reference to 'value' is ambiguous
```

Квалифицированное обращение при этом работает. Переменные в неймспейсе, как и глобальные, инициализируются значениями по умолчанию:

```cpp
#include <iostream>

namespace lib {
    int value; // Как и глобальные переменные, инициализируются default значениями
}

int value;

int main() {
    using namespace lib;
    std::cout << lib::value << std::endl; // 0
}
```

Директиву можно применять и к вложенному неймспейсу: `inner` ищется среди уже подключённых пространств.

```cpp
#include <iostream>

namespace outer {
    namespace inner {
        int value = 2;
    }
}

int main() {
    using namespace outer;
    using namespace inner; // Здесь мы ищем inner среди уже подключённых неймспейсов и находим

    std::cout << value << std::endl; // 2; если бы не подключили inner, то не нашли бы
}
```

=== Дополнение и вложенность

Неймспейсы можно объявлять по частям — новое объявление дополняет уже созданный неймспейс, и имена из первой части видны во второй:

```cpp
#include <iostream>

namespace math {
    int base = 1;
}

namespace math { // дополняет уже созданный namespace
    int derived = base + 2; // base виден из первой части
}

int main() {
    std::cout << math::base << " " << math::derived << std::endl; // 1 3
}
```

Так же дополняются и вложенные неймспейсы:

```cpp
#include <iostream>

namespace outer {
    namespace inner {
        int alpha = 3;
    }

    int beta = 2;
}

namespace outer {
    int alpha = 1;
}

namespace outer {
    namespace inner {
        int beta = 4;
    }
}

int main() {
    std::cout << outer::alpha << outer::beta
              << outer::inner::alpha << outer::inner::beta << std::endl; // 1234
}
```

Есть сокращённая запись вложенных неймспейсов:

```cpp
#include <iostream>

namespace app::net::http {
    int value = 7;
}

/* Раскрывается так:
namespace app {
    namespace net {
        namespace http {
            int value = 7;
        }
    }
}
*/

namespace app::net {
    int other = http::value + 1; // http виден изнутри app::net
}

int main() {
    std::cout << app::net::http::value << std::endl; // 7
    std::cout << app::net::other << std::endl;       // 8
}
```

=== Поиск имён

Неквалифицированное имя ищется изнутри наружу: сначала в текущем неймспейсе, затем в объемлющих, затем в глобальной области. `::` в начале форсирует поиск от глобальной области. Имена переменных здесь названы по тому, откуда пришло значение:

```cpp
#include <iostream>

namespace shared {
    int value = 2;
}

namespace app {
    int value = 5;
}

namespace app::inner {
    int from_global = ::shared::value + 1;  // Ищем в глобальной области видимости
    int from_lookup = shared::value + 1;    // Ищем namespace shared сначала в inner, затем
                                            // в app и только потом в глобальной области
    int from_enclosing = value + 1;         // Найдётся в app
}

int main() {
    std::cout << app::inner::from_global << std::endl;    // 3
    std::cout << app::inner::from_lookup << std::endl;    // 3
    std::cout << app::inner::from_enclosing << std::endl; // 6
}
```

Видно только то, что объявлено выше по тексту: здесь `lib::derived` считается по глобальному `value`, потому что `lib::value` появляется ниже:

```cpp
#include <iostream>

int value = 2;

namespace lib {
    int derived = value + 1; // lib::value ещё нет — берётся глобальный 2
}

namespace lib {
    int value = 1;
}

int main() {
    std::cout << lib::derived << std::endl; // 3
}
```

Квалификатором можно точно указать нужное имя даже при затенении:

```cpp
#include <iostream>

int value = 1;

namespace app {
    int value = 2;

    namespace inner {
        int result = ::app::value + 3; // именно app::value, а не глобальный
    }
}

int main() {
    std::cout << app::inner::result << std::endl; // 5
}
```

=== `using` внутри неймспейсов

Можно использовать неймспейсы внутри других неймспейсов. Имя становится доступным при поиске — в том числе снаружи, через это пространство:

```cpp
#include <iostream>

namespace base {
    int value = 1;
}

namespace derived {
    using namespace base; // можно использовать неймспейсы внутри других неймспейсов

    int sum = value + 4;
}

int main() {
    std::cout << derived::sum << std::endl;   // 5
    std::cout << derived::value << std::endl; // Скомпилируется, так как имя value становится
                                              // доступным при поиске. 1
}
```

То же самое, но без собственных переменных — обращение `derived::value` всё равно работает:

```cpp
#include <iostream>

namespace base {
    int value = 1;
}

namespace derived {
    using namespace base;
}

int main() {
    std::cout << derived::value << std::endl; // 1
}
```

А `using`-объявление вводит имя в неймспейс `derived`, и тогда собственный `value` создать уже нельзя:

```cpp
#include <iostream>

namespace base {
    int value = 1;
}

namespace derived {
    using base::value; // Так тоже можно, однако теперь мы уже вводим value в пространство
                       // имён неймспейса derived и не можем создать новый value
    // int value = 2; — ошибка
    int sum = value + 4;
}

int main() {
    std::cout << derived::sum << std::endl;   // 5
    std::cout << derived::value << std::endl; // 1
}
```

С `using`-директивой такой ошибки не будет — собственный `value` заводится нормально и оказывается приоритетнее:

```cpp
#include <iostream>

namespace base {
    int value = 1;
}

namespace derived {
    using namespace base;
    int sum = value + 4; // здесь value ещё из base, поэтому 5
    int value = 2;       // А вот так ошибки не будет
}

int main() {
    std::cout << derived::sum << std::endl;   // 5
    std::cout << derived::value << std::endl; // 2
}
```

=== Псевдонимы

Длинным именам неймспейсов можно давать алиасы:

```cpp
#include <iostream>

namespace VeryLongNamespaceName {
    namespace Inner {
        int value = 42;
    }
}

namespace V = VeryLongNamespaceName; // можно делать алиасы на имена неймспейсов

int main() {
    std::cout << V::Inner::value << std::endl; // 42

    int V = 10;

    std::cout << V << std::endl;                                   // 10
    std::cout << VeryLongNamespaceName::Inner::value << std::endl; // 42
}
```

Отдельный тонкий момент: локальная переменная с именем алиаса *не мешает* использовать алиас как квалификатор. В квалифицированном имени `X::` поиск рассматривает только неймспейсы, типы и шаблоны, а переменные игнорирует — поэтому оба обращения работают:

```cpp
#include <iostream>

namespace lib {
    int value = 1;
}

namespace shortcut = lib;

int main() {
    int shortcut = 10;

    std::cout << shortcut << ' ' << shortcut::value << std::endl; // 10 1 — компилируется!
}
```

Проверено на `clang++` и `g++`: оба печатают `10 1`. А вот если бы неймспейса или типа с таким именем не существовало вовсе, то квалификатор действительно был бы ошибкой:

```cpp
int main() {
    int B = 10;
    std::cout << B::x;
}
```

```text
error: 'B' is not a class, namespace, or enumeration
```

Алиас можно сделать и на вложенный неймспейс:

```cpp
#include <iostream>

namespace outer {
    namespace inner {
        int value = 7;
    }
}

namespace oi = outer::inner;

int main() {
    std::cout << oi::value << std::endl; // 7
}
```

Сокращённая запись и обращение к вложенному имени изнутри объемлющего:

```cpp
#include <iostream>

namespace app::config {
    int value = 7;
}

namespace app {
    int next = config::value + 1; // config виден изнутри app
}

int main() {
    std::cout << app::next << std::endl; // 8
}
```

== `extern`

Ключевое слово `extern` говорит, что переменная определена где-то в другом месте, то есть это declaration only:

```cpp
#include <iostream>

extern int value; // Ключевое слово extern говорит, что переменная defined где-то в другом
                  // месте. То есть declaration only

int main() {
    std::cout << value << std::endl; // 10
}

// value = 10; — так будет ошибка, так как это statement only
int value = 10; // без этой строки была бы ошибка линковки, так как value не определена
```

`extern` можно писать и внутри функций:

```cpp
#include <iostream>

int main() {
    extern int value; // extern можно писать и внутри функций (где-то есть определение)
    std::cout << value << std::endl; // 42
}

int value = 42;
```

Но второе объявление того же имени в том же scope — уже ошибка:

```cpp
#include <iostream>

int main() {
    extern int value;
    int value = 7; // А вот тут ошибка — второе value в том же scope

    std::cout << value << std::endl;
}

int value = 42;
```

`extern` работает и для имён внутри неймспейсов: определить `app::value` снаружи можно, только если внутри `app` она объявлена как `extern`. А `empty::value` определить нельзя — в `empty` такого имени нет:

```cpp
#include <iostream>

int value = 1;

namespace app {
    extern int value; // Где-то есть app::value
    int derived = value + 1;
}

int main() {
    std::cout << app::derived << std::endl; // 11
}

namespace empty {}

int app::value = 10;  // Так можно, только если внутри namespace переменная объявлена как extern
int empty::value = 2; // А так нельзя, так как внутри empty нет value
```

```text
error: no member named 'value' in namespace 'empty'
```
