# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

### Вопрос

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [elasticsearch:7](https://hub.docker.com/_/elasticsearch) как базовый:

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib` 
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения
- обратите внимание на настройки безопасности такие как `xpack.security.enabled` 
- если докер образ не запускается и падает с ошибкой 137 в этом случае может помочь настройка `-e ES_HEAP_SIZE`
- при настройке `path` возможно потребуется настройка прав доступа на директорию

Далее мы будем работать с данным экземпляром elasticsearch.

### Ответ

**Текст Dockerfile манифеста**

```dockerfile
FROM elasticsearch:8.2.3

USER root

RUN mkdir /var/lib/log && \
    chown elasticsearch /var/lib/log &&\
    mkdir /var/lib/data && \
    chown elasticsearch /var/lib/data

COPY --chown=elasticsearch elasticsearch.yml /usr/share/elasticsearch/config/

USER elasticsearch
```

**Cсылкa на образ в репозитории dockerhub**

https://hub.docker.com/repository/docker/rdbmw/elastic_net

**Ответ `elasticsearch` на запрос пути `/` в json виде**

```bash
rdbmw@rdbmw-desktop:~/1/src$ curl -k -u elastic  https://localhost:9200
Enter host password for user 'elastic':
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "7I-K8nOeSbGh0gvDwD-GVQ",
  "version" : {
    "number" : "8.2.3",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "9905bfb62a3f0b044948376b4f607f70a8a151b4",
    "build_date" : "2022-06-08T22:21:36.455508792Z",
    "build_snapshot" : false,
    "lucene_version" : "9.1.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

### Вопрос

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

### Ответ

**Список индексов**

```bash
rdbmw@rdbmw-desktop:~$ curl -k -u elastic  https://localhost:9200/_cat/indices?v=true
Enter host password for user 'elastic':
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 UfCi17w1R_2mQtD3WAvMxA   1   0          0            0       225b           225b
yellow open   ind-2 5AXWmTDQRbOFNw3_dBc-tw   2   1          0            0       450b           450b
yellow open   ind-3 kPOJV-whSP25fFV__IQupA   4   2          0            0       900b           900b
```

Часть индексов и кластер находится в состоянии yellow, т.к. elastic развернут на одной ноде. Для корректной работы необходимо хотя бы две машины.

## Задача 3

### Вопрос

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

### Ответ

**Создание репозитория**

```bash
rdbmw@rdbmw-desktop:~$ curl -k -u elastic -X PUT 'https://localhost:9200/_snapshot/netology_backup?pretty' -H 'Content-Type: application/json' -d '{  "type": "fs",  "settings": {    "location": "snapshots"  } }'
Enter host password for user 'elastic':
{
  "acknowledged" : true
}
```

**Создание индекса**

```bash
rdbmw@rdbmw-desktop:~$ curl -k -u elastic  https://localhost:9200/_cat/indices?v=true
Enter host password for user 'elastic':
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  _iRqOGa7TJ6TW-_ewL7ktQ   1   0          0            0       225b           225b
```

**Файлы в директории**

```bash
elasticsearch@35d81e17a515:~/snapshots$ ls -al
total 44
drwxrwxr-x 3 elasticsearch elasticsearch  4096 Jun 26 19:10 .
drwxrwxr-x 3 elasticsearch elasticsearch  4096 Jun 26 19:03 ..
-rw-rw-r-- 1 elasticsearch elasticsearch  1096 Jun 26 19:10 index-0
-rw-rw-r-- 1 elasticsearch elasticsearch     8 Jun 26 19:10 index.latest
drwxrwxr-x 5 elasticsearch elasticsearch  4096 Jun 26 19:10 indices
-rw-rw-r-- 1 elasticsearch elasticsearch 18490 Jun 26 19:10 meta-TqW6SdfzSeC99aeboqvggw.dat
-rw-rw-r-- 1 elasticsearch elasticsearch   383 Jun 26 19:10 snap-TqW6SdfzSeC99aeboqvggw.dat
```

**Список индексов после удаления test и создания test-2**

```bash
rdbmw@rdbmw-desktop:~$ curl -k -u elastic  https://localhost:9200/_cat/indices?v=true
Enter host password for user 'elastic':
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 7c5PWv_pQlqmOeMNGnGgWQ   1   0          0            0       225b           225b
```

**Восстановление snapshot**

```bash
rdbmw@rdbmw-desktop:~$ curl -k -u elastic -X POST "https://localhost:9200/_snapshot/netology_backup/my_snapshot/_restore?pretty"
Enter host password for user 'elastic':
{
  "accepted" : true
}

rdbmw@rdbmw-desktop:~$ curl -k -u elastic  https://localhost:9200/_cat/indices?v=true
Enter host password for user 'elastic':
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 7c5PWv_pQlqmOeMNGnGgWQ   1   0          0            0       225b           225b
green  open   test   Czw4DF3rSyG1THejBFRf9A   1   0          0            0       225b           225b
```