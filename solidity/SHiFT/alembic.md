### Make migration
```
alembic init alembic
// in alembic.ini:
sqlalchemy.url = postgresql://user:password@localhost:5432/mydatabase

// in alembic/env.py
from your_model_file import Base  # Импортируйте ваш базовый класс (ORM)
target_metadata = Base.metadata

alembic revision --autogenerate -m "Initial migration"
alembic upgrade head
```

### errors
```
➜  xparser alembic revision --autogenerate -m "Initial migration1"
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
ERROR [alembic.util.messaging] Can't locate revision identified by '3000a7f2a848'
  FAILED: Can't locate revision identified by '3000a7f2a848'
```

Solution (in postgres):
```bash
DELETE FROM alembic_version WHERE version_num = '3000a7f2a848';
```
