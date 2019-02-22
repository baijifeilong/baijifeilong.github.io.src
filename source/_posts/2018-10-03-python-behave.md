---
title: Python Behave 测试框架示例
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - Test
  - TDD
  - Behave
date: 2018-10-03 23:59:35
---

## Gherkin

**number.feature**

```gherkin
Feature: Number

  Scenario Outline: Add
    Given I have a number <a>
    When I plus the number with <b>
    Then it should equals to <a+b>

    Examples: examples
      | a  | b | a+b |
      | 1  | 1 | 2   |
      | 0  | 0 | 0   |
      | -1 | 1 | 0   |
```

<!--more-->

## Python测试脚本

**steps/number.py**

```python
from behave import given, when, then


class Number(object):
    def __init__(self, value):
        self.value = value

    def plus(self, another):
        self.value += another


the_number: Number = None


@given('I have a number {a}')
def step_given_a_number_a(context, a):
    global the_number
    the_number = Number(int(a))


@when('I plus the number with {b}')
def step_when_plus_a_number_b(context, b):
    global the_number
    the_number.plus(int(b))


@then('it should equals to {c}')
def step_then_it_should_equals(context, c):
    global the_number
    assert the_number.value == int(c)
```

## 运行

`behave`

## 输出

```
Feature: Number # number.feature:1

  Scenario Outline: Add -- @1.1 examples  # number.feature:10
    Given I have a number 1               # steps/number.py:15 0.000s
    When I plus the number with 1         # steps/number.py:21 0.000s
    Then it should equals to 2            # steps/number.py:27 0.000s

  Scenario Outline: Add -- @1.2 examples  # number.feature:11
    Given I have a number 0               # steps/number.py:15 0.000s
    When I plus the number with 0         # steps/number.py:21 0.000s
    Then it should equals to 0            # steps/number.py:27 0.000s

  Scenario Outline: Add -- @1.3 examples  # number.feature:12
    Given I have a number -1              # steps/number.py:15 0.000s
    When I plus the number with 1         # steps/number.py:21 0.000s
    Then it should equals to 0            # steps/number.py:27 0.000s

1 feature passed, 0 failed, 0 skipped
3 scenarios passed, 0 failed, 0 skipped
9 steps passed, 0 failed, 0 skipped, 0 undefined
Took 0m0.001s
```
