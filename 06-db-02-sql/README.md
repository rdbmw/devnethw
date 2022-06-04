# Домашнее задание к занятию "6.2. SQL"

## Задача 1

### Вопрос

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

### Ответ

```bash
docker run -dp 5432:5432 \
	--name postgres-netology \
	-e POSTGRES_PASSWORD=postgres123 \
	-v ~/src/bd:/var/lib/postgresql/data \
	-v ~/src/backup:/backup \
	postgres:12
```

## Задача 2

### Вопрос

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

### Ответ

**SQL-запросы:**

CREATE USER test-admin-user;

CREATE USER test-simple-user;

CREATE DATABASE test_db;

CREATE TABLE orders (id serial PRIMARY KEY, title varchar(50), price integer);

CREATE TABLE clients (id serial PRIMARY KEY, surname varchar(50), country varchar(20), order_id integer REFERENCES orders);

CREATE INDEX country_idx ON clients (country);

GRANT ALL ON orders, clients TO test-admin-user;

GRANT SELECT, INSERT, UPDATE, DELETE  ON orders, clients TO test-simple-user;

SELECT * FROM information_schema.table_privileges WHERE grantee IN ('test-admin-user', 'test-simple-user') AND table_name IN ('orders', 'clients');

**Список БД:**

```
test_db=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)

```
**Таблица ordes:**

```
test_db=# \d orders
                                   Table "public.orders"
 Column |         Type          | Collation | Nullable |              Default               
--------+-----------------------+-----------+----------+------------------------------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass)
 title  | character varying(50) |           |          | 
 price  | integer               |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)
```

**Таблица clients:**

```
test_db=# \d clients
                                    Table "public.clients"
  Column  |         Type          | Collation | Nullable |               Default               
----------+-----------------------+-----------+----------+-------------------------------------
 id       | integer               |           | not null | nextval('clients_id_seq'::regclass)
 surname  | character varying(50) |           |          | 
 country  | character varying(20) |           |          | 
 order_id | integer               |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "country_idx" btree (country)
Foreign-key constraints:
    "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)
```

**Список прав пользователей:**

```
test_db=# SELECT * FROM information_schema.table_privileges WHERE grantee IN ('test-admin-user', 'test-simple-user') AND table_name IN ('orders', 'clients');
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy 
----------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | test-admin-user  | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-admin-user  | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | TRUNCATE       | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | REFERENCES     | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | TRIGGER        | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-admin-user  | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | DELETE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | TRUNCATE       | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | REFERENCES     | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clients    | TRIGGER        | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | DELETE         | NO           | NO
(22 rows)

```


## Задача 3

### Вопрос

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.


### Ответ

INSERT INTO orders VALUES
    (DEFAULT, 'Шоколад', 10),
    (DEFAULT, 'Принтер', 3000),
    (DEFAULT, 'Книга', 500),
    (DEFAULT, 'Монитор', 7000),
    (DEFAULT, 'Гитара', 4000);

```
test_db=# SELECT * FROM orders;
 id |  title  | price 
----+---------+-------
  1 | Шоколад |    10
  2 | Принтер |  3000
  3 | Книга   |   500
  4 | Монитор |  7000
  5 | Гитара  |  4000
(5 rows)

```

INSERT INTO clients (surname, country) VALUES
    ('Иванов Иван Иванович', 'USA'),
    ('Петров Петр Петрович', 'Canada'),
    ('Иоганн Себастьян Бах', 'Japan'),
    ('Ронни Джеймс Дио', 'Russia'),
    ('Ritchie Blackmore', 'Russia');

```
test_db=# SELECT * FROM clients;                                                                                                
 id |       surname        | country | order_id 
----+----------------------+---------+----------
  1 | Иванов Иван Иванович | USA     |         
  2 | Петров Петр Петрович | Canada  |         
  3 | Иоганн Себастьян Бах  | Japan   |         
  4 | Ронни Джеймс Дио     | Russia  |         
  5 | Ritchie Blackmore    | Russia  |         
(5 rows)
```

**Количество записей**

```
test_db=# SELECT count(*) FROM clients;
 count 
-------
     5
(1 row)

test_db=# SELECT count(*) FROM orders;
 count 
-------
     5
(1 row)
```

## Задача 4

### Вопрос

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

### Ответ

UPDATE clients SET order_id = 3 WHERE surname = 'Иванов Иван Иванович';
UPDATE clients SET order_id = 4 WHERE surname = 'Петров Петр Петрович';
UPDATE clients SET order_id = 5 WHERE surname = 'Иоганн Себастьян Бах';

```
test_db=# UPDATE clients SET order_id = 3 WHERE surname = 'Иванов Иван Иванович';
UPDATE 1
test_db=# UPDATE clients SET order_id = 4 WHERE surname = 'Петров Петр Петрович';
UPDATE 1
test_db=# UPDATE clients SET order_id = 5 WHERE surname = 'Иоганн Себастьян Бах';
UPDATE 1
```

SELECT * FROM clients WHERE order_id IS NOT NULL;
```
test_db=# SELECT * FROM clients WHERE order_id IS NOT NULL;
 id |       surname        | country | order_id 
----+----------------------+---------+----------
  1 | Иванов Иван Иванович | USA     |        3
  2 | Петров Петр Петрович | Canada  |        4
  3 | Иоганн Себастьян Бах | Japan   |        5
(3 rows)
```

## Задача 5

### Вопрос

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

### Ответ

```
test_db=# EXPLAIN (FORMAT JSON) SELECT * FROM clients WHERE order_id IS NOT NULL;
                QUERY PLAN                
------------------------------------------
 [                                       +
   {                                     +
     "Plan": {                           +
       "Node Type": "Seq Scan",          +
       "Parallel Aware": false,          +
       "Relation Name": "clients",       +
       "Alias": "clients",               +
       "Startup Cost": 0.00,             +
       "Total Cost": 13.80,              +
       "Plan Rows": 378,                 +
       "Plan Width": 184,                +
       "Filter": "(order_id IS NOT NULL)"+
     }                                   +
   }                                     +
 ]
(1 row)
```

Получили следующе данные:
- Node Type (Seq Scan) — последовательное, блок за блоком, чтение данных таблицы;
- Parallel Aware — параллельное сканирование;
- Relation Name, Alias —  наименование таблицы;
- Startup Cost — затраты на получение первой строки;
- Total Cost — затраты на получение всех строк;
- Plan Rows — приблизительное количество возвращаемых строк при выполнении операции Seq Scan;
- Plan Width — средний размер одной строки в байтах;
- Filter — применяемый в запросе фильтр.



## Задача 6

### Вопрос

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

### Ответ

**Создание бэкапа**

Производим командой pg_dump  
```
root@8878e3b87863:/# pg_dump -U postgres test_db > /backup/test_db.dump
root@8878e3b87863:/# ls -al /backup
total 16
drwxr-xr-x 2 root root 4096 Jun  4 18:12 .
drwxr-xr-x 1 root root 4096 Jun  3 18:57 ..
-rw-r--r-- 1 root root 4136 Jun  4 18:12 test_db.dump
```

**Запуск нового контейнера**

Делаем аналогично задаче 1, монитирую volume /backup/
```
rdbmw@rdbmw-desktop:~$ sudo docker run -dp 5432:5432 \
> --name postgres-netology1 \
> -e POSTGRES_PASSWORD=postgres123 \
> -v ~/src/backup:/backup \
> postgres:12
f2feba541067a6860400bef2fab0795612e15b6c365e416706d9fe083512ccc1
rdbmw@rdbmw-desktop:~$ sudo docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS                      PORTS                                       NAMES
f2feba541067   postgres:12   "docker-entrypoint.s…"   4 seconds ago   Up 2 seconds                0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres-netology1
8878e3b87863   postgres:12   "docker-entrypoint.s…"   24 hours ago    Exited (0) 56 seconds ago                                               postgres-netology
```

**Копирование из бэкапа**

Создаем в новом контейнере базу test_db и восстанавливаем бэкап через psql.

```
rdbmw@rdbmw-desktop:~$ sudo docker exec -it postgres-netology1 /bin/bash
root@f2feba541067:/# psql -U postgres
psql (12.11 (Debian 12.11-1.pgdg110+1))
Type "help" for help.

postgres=# CREATE DATABASE test_db;
CREATE DATABASE
postgres=# quit
root@f2feba541067:/# psql -U postgres test_db < /backup/test_db.dump
[... длинный вывод ...] 
```

