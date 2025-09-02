---
title: JavaScript 类型转换
date: 2025-09-02 19:36:01
tags: [Guide, Lang, JavaScript]
category: [Guide, Lang, JavaScript]
thumbnail: /image/javascript-type-conversion/head.webp
excerpt: 随便聊聊自己的一点想法
---

## 前言

### 额外说明

本文以 TypeScript 进行讲解，不过不用担心，JavaScript 仍然适用，因为 TypeScript 只是对 JavaScript 包装了一层类型而已（只在编译期间存在的抽象 layer）。

### 勘误

在深入研究文本之前，请务必注意可能存在一些 **语法错误** ，这可能是由于翻译错误、打字错误或作者独特的写作风格。

如果你有疑问或者建议，欢迎在评论区留言，或通过邮箱 shetty@shettydev.com 联系。

## 杂项

JavaScript 的基本特征：

- 父类/子类转换与 Java 语言十分类似，没什么好说的。

- 基本类型 `string`、`number` 都是包装类型，即可以直接通过“instance.function”的方式调用成员函数。

## 强制类型转换

### 定义

`as` 关键字可以将一个类型转换为另一个类型：

```typescript
const a = A();
let b = a as B;
```

将 a 称为左端，b 称为右端。操蛋的事实是：右端将得到左端的**所有成员**，不论是否存在定义。

### 示例代码

以下是一个简单的测试脚本，你可以使用 `node` 命令运行它：

```typescript
type A = {
  a: number, b: number, c: number
};

type B = {
  a: number, b: number, d: number
};

function test() {
  const a_instance: A = { a: 1, b: 2, c: 3 };
  console.log("a_instance is", a_instance);

  const b_instance = a_instance as B;
  console.log("b_instance is", b_instance);
}

test()
```

输出：

```bash
$ node test.ts
a_instance is { a: 1, b: 2, c: 3 }
b_instance is { a: 1, b: 2, c: 3 }
```

b\_instance 变量只是换了一个类型的标签，实际上类型仍然是 A。

即便两个类型的 field 完全一致，`as` 仍然不会改变实质的类型，将 A 强制转化为 B 后，调用 B 的成员函数会导致函数不存在的运行时异常：

```typescript
class A {
	a: number;
	constructor(a: number) {
		this.a = a;
	}

	// no methods
};

class B {
	a: number;
	constructor(a: number) {
		this.a = a;
	}

	doSomething() {
		console.log("Doing something with a =", this.a);
	}
};

function test() {
	const a_instance = new A(0);
	console.log("a_instance is", a_instance);

  const b_instance = a_instance as B;
	console.log("b_instance is", b_instance);

	b_instance.doSomething();
}

test()
```

抛出异常：

```bash
❯ node test.ts
a_instance is A { a: 0 }
b_instance is A { a: 0 }
/home/yttehs/test.ts:28
	b_instance.doSomething();
	          ^

TypeError: b_instance.doSomething is not a function
    at test (/home/yttehs/test.ts:28:13)
    at Object.<anonymous> (/home/yttehs/test.ts:31:1)
    at Module._compile (node:internal/modules/cjs/loader:1738:14)
    at Object..js (node:internal/modules/cjs/loader:1871:10)
    at Module.load (node:internal/modules/cjs/loader:1470:32)
    at Module._load (node:internal/modules/cjs/loader:1290:12)
    at TracingChannel.traceSync (node:diagnostics_channel:322:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:238:24)
    at Module.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:154:5)
    at node:internal/main/run_main_module:33:47

Node.js v24.7.0
```

因此，在项目开发中，尽可能不使用 `as` 关键字，这可能会产生潜在的问题，然而语法检查却始终 happy。

### 解决方式

{% notel yellow Warn %}
作者并不是这方面的专家，只能根据自己的经验说明。
{% endnotel %}

举一个业务常见的例子，有两个类型，一个是数据类，另一个是 UI 类，在渲染之前需要将数据类转化为 UI 类。

这是两个类型，要求 UI 类的属性只能是只读，并且不能包含敏感的 field3 属性：

```typescript
class Foo {
  private _field1: string;
  get field1() { return this._field1; }
  set field1(value: string) { this._field1 = value; }

  private _field2: number;
  get field2() { return this._field2; }

  private _field3: boolean;
  get field3() { return this._field3; }

  constructor(field1: string, field2: number, field3: boolean) {
    this._field1 = field1;
    this._field2 = field2;
    this._field3 = field3;
  }
}

class FooUiState {
  private _field1: string;
  get field1() { return this._field1; }

  private _field2: number;
  get field2() { return this._field2; }

  constructor(field1: string, field2: number) {
    this._field1 = field1;
    this._field2 = field2;
  }
}
```

从数据库/云端得到 `Foo` 类型，创建“to”前缀的函数用于类型转换：

```typescript
class Foo {
  // ...

  toUiState() {
    return new FooUiState(this.field1, this.field2);
  }
}
```

使用时，调用 `foo.toUiState()` 即可获得 FooUiState 实例，`new` 关键字保证了类型是正确的。
