# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

### Вопрос

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

### Ответ

Команда на запуск контейнера:

```bash
docker run -dp 5432:5432 \
	--name postgres-netology \
	-e POSTGRES_PASSWORD=postgres123 \
	-v ~/src/backup:/backup \
	postgres:13
```

**Вывод списка БД**

команда "\l"

```
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```

**Подключение к БД**

Команда "\c"

```
postgres=# \c template1
Password: 
You are now connected to database "template1" as user "postgres".
template1=# 
```

**Вывода списка таблиц**

Команда "\dt"

```
test_database=# \dt
         List of relations
 Schema |  Name  | Type  |  Owner   
--------+--------+-------+----------
 public | orders | table | postgres
(1 row)
```

**Вывод описания содержимого таблиц**
 
Команда "\d NAME"

```
test_database=# \d orders
                                   Table "public.orders"
 Column |         Type          | Collation | Nullable |              Default               
--------+-----------------------+-----------+----------+------------------------------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass)
 title  | character varying(80) |           | not null | 
 price  | integer               |           |          | 0
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
```

**Выход из psql**

Команда "\q"

## Задача 2

### Вопрос

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

### Ответ

**Команда восстановление базы из дампа**

psql -U postgres test_database < /backup/test_dump.sql 

**Запрос на поиск столбца с наибольшим средним значение размера элементов в байтах:**

SELECT attname, avg_width FROM pg_stats WHERE tablename='orders' ORDER BY avg_width DESC LIMIT 1;


## Задача 3

### Вопрос

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

### Ответ

**Шардинг существующей через создание новых таблиц:**

CREATE TABLE orders_new_ (id integer, title varchar(80), price integer);

CREATE TABLE orders__2 (
  CHECK ( price<=499 )
) INHERITS ( orders_new_ );

CREATE TABLE orders__1 (
  CHECK ( price>499 )
) INHERITS ( orders_new_ );

**Устанавливаем правила:**

CREATE RULE price_over_499 AS ON INSERT TO orders_new_
WHERE ( price>499 )
DO INSTEAD INSERT INTO orders__1 VALUES (NEW.*);

CREATE RULE price_under_499 AS ON INSERT TO orders_new_
WHERE ( price<=499 )
DO INSTEAD INSERT INTO orders__2 VALUES (NEW.*);

**Переносим данные:**

INSERT INTO orders_new_ SELECT * FROM orders;

**Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?**

Да, эти правила можно было указать при первоначальном проектировании.

## Задача 4

### Вопрос

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

### Ответ

**Создание дампа** 

```
root@554ca809ec56:/# pg_dump -U postgres -d test_database > /backup/test_database_dump.sql
root@554ca809ec56:/# ls -al backup/
total 20
drwxr-xr-x 2 root root 4096 Jun 18 21:13 .
drwxr-xr-x 1 root root 4096 Jun 18 19:22 ..
-rw-r--r-- 1 root root 7218 Jun 18 21:13 test_database_dump.sql
-rwxr-x--- 1 root root 2082 Jun 18 19:47 test_dump.sql
```

**Уникальность столбца**

Через добавление свойство UNIQUE

```
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL UNIQUE,
    price integer DEFAULT 0
);
```