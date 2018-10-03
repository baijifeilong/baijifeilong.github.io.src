---
title: SQLAlchemy示例
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - Database
  - ORM
date: 2018-10-04 00:08:03
---

## 示例代码

```python
import sqlalchemy
from sqlalchemy import Column, MetaData, Integer, String, distinct
from sqlalchemy.engine import Engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

Base = declarative_base()


class Car(Base):
    __tablename__ = 'car'
    id = Column('id', Integer, primary_key=True)
    name = Column('name', String(50), nullable=False, unique=True)
    age = Column('age', Integer, default=0, nullable=False)

    def __init__(self, name):
        self.name = name

    def __str__(self):
        return f'Car({self.id}:{self.name}:{self.age})'

    def __repr__(self):
        return self.__str__()


metadata: MetaData = Base.metadata
engine: Engine = sqlalchemy.engine.create_engine('mysql+pymysql://foo:foo@localhost:3306/foo', echo=False)
session: Session = sessionmaker(engine)()
metadata.create_all(engine)

session.query(Car).delete()
session.execute('TRUNCATE car')
session.add(Car('Audi'))
session.add(Car('Benz'))
session.add(Car('BMW'))
session.commit()
print(session.execute("SELECT * FROM car").fetchall())
print(session.query(Car).all())
print(session.query(Car).filter(Car.id > 1).all())
print(session.query(distinct(Car.age)).all())
print(session.query(Car).count())

```

## 输出

```
[(1, 'Audi', 0), (2, 'Benz', 0), (3, 'BMW', 0)]
[Car(1:Audi:0), Car(2:Benz:0), Car(3:BMW:0)]
[Car(2:Benz:0), Car(3:BMW:0)]
[(0,)]
3
```
