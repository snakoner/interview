```psql
CREATE TABLE owners (
  id serial primary key,
  name text not null
);

CREATE TABLE wallets (
  id serial primary key,
  owner_id integer not null,
  wallet text not null
);

INSERT INTO owners(name) VALUES('Andrey Stroganov');
INSERT INTO owners(name) VALUES('Victor Kazantsev');

INSERT INTO wallets(owner_id, wallet) VALUES(1, '0xac58ADe8AAF0A8322259496EaDCC16dBF73Db279');
INSERT INTO wallets(owner_id, wallet) VALUES(1, '0xbc58ADe8AAF0A8322259496EaDCC16dBF73Db279');
INSERT INTO wallets(owner_id, wallet) VALUES(2, '0xbc58ADe8AAF0A8322259496EaDCC16dBF73AA279');

```
