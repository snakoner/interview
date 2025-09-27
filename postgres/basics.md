
```sql
CREATE TABLE owners (
  id serial primary key,
  name text not null
);

CREATE TABLE wallets (
  id serial primary key,
  owner_id integer not null,
  wallet text not null
);


INSERT INTO owners(name) values('Andrey Stroganov');
INSERT INTO owners(name) values('Victor Kazantsev');
INSERT INTO owners(name) values('Petr Ivanov');

INSERT INTO wallets(owner_id, wallet) values(1, '0xac58ADe8AAF0A8322259496EaDCC16dBF73Db279');
INSERT INTO wallets(owner_id, wallet) values(1, '0xbc58ADe8AAF0A8322259496EaDCC16dBF73Db279');
INSERT INTO wallets(owner_id, wallet) values(2, '0xbc58ADe8AAF0A8322259496EaDCC16dBF73AA279');
INSERT INTO wallets(owner_id, wallet) values(4, '0xDEB8ADe8AAF0A8322259496EaDCC16dBF73AA279');

SELECT * FROM owners;
SELECT * FROM wallets;
```

```
 id |       name       
----+------------------
  1 | Andrey Stroganov
  2 | Victor Kazantsev
  3 | Petr Ivanov
(3 rows)

 id | owner_id |                   wallet                   
----+----------+--------------------------------------------
  1 |        1 | 0xac58ADe8AAF0A8322259496EaDCC16dBF73Db279
  2 |        1 | 0xbc58ADe8AAF0A8322259496EaDCC16dBF73Db279
  3 |        2 | 0xFFF8ADe8AAF0A8322259496EaDCC16dBF73AA279
  4 |        4 | 0xDEB8ADe8AAF0A8322259496EaDCC16dBF73AA279
(4 rows)
```



```sql
// получить все строчки, в которых есть совпадение по o.id, w.owner_id
SELECT o.name, w.wallet FROM
  owners o
JOIN wallets w
ON o.id = w.owner_id;

       name       |                   wallet                   
------------------+--------------------------------------------
 Andrey Stroganov | 0xac58ADe8AAF0A8322259496EaDCC16dBF73Db279
 Andrey Stroganov | 0xbc58ADe8AAF0A8322259496EaDCC16dBF73Db279
 Victor Kazantsev | 0xFFF8ADe8AAF0A8322259496EaDCC16dBF73AA279
```



```sql
// получить ВСЕ строчки из первой таблицы, и сопоставить им значения из второй, если такие есть, если нет - пусто
SELECT o.name, w.wallet FROM
  owners o
LEFT JOIN wallets w
ON o.id = w.owner_id;

       name       |                   wallet                   
------------------+--------------------------------------------
 Andrey Stroganov | 0xac58ADe8AAF0A8322259496EaDCC16dBF73Db279
 Andrey Stroganov | 0xbc58ADe8AAF0A8322259496EaDCC16dBF73Db279
 Victor Kazantsev | 0xFFF8ADe8AAF0A8322259496EaDCC16dBF73AA279
 Petr Ivanov      | 
```

```sql
// получить все кошельки конкретного пользователя
SELECT o.name, w.wallet
FROM owners o
LEFT JOIN wallets w
  ON o.id = w.owner_id
WHERE o.name = 'Andrey Stroganov';

       name       |                   wallet                   
------------------+--------------------------------------------
 Andrey Stroganov | 0xac58ADe8AAF0A8322259496EaDCC16dBF73Db279
 Andrey Stroganov | 0xbc58ADe8AAF0A8322259496EaDCC16dBF73Db279
```

