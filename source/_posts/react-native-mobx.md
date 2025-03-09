---
title: React Native MobX
date: 2025-03-09 19:43:43
tags: [Guide, Framework, React]
category: [Gudie, Framework]
thumbnail: /image/react-native-mobx/head.webp
excerpt: 如何在 React Native 项目中实现 MVVM 架构
---

## 前言

头像来自 [MobX 官网](https://mobx.js.org)。

### 什么是 MobX

[MobX](https://mobx.js.org) 是一个基于信号的、经过实战检验的库，它通过透明地应用函数式响应式编程，使状态管理变得简单且可扩展。（翻译自官网）

### 勘误

在深入研究文本之前，请务必注意可能存在一些 **语法错误** ，这可能是由于翻译错误、打字错误或作者独特的写作风格。

如果你有疑问或者建议，欢迎在评论区留言，或通过邮箱 shetty@shettydev.com 联系。

## 了解 MVVM

MVVM 是前端 / APP 开发常用的模式，旨在将数据处理与 UI 的代码分离，进一步解耦，增强项目的可维护性。

MVVM 分为 3 个部分：

- M (Modal): 数据模型，通常有多个，由业务决定。

- V (View): 视图，看得到的东西，比如 Navigation 页面。

- VM (View Modal): 视图模型，通常情况与 Modal 是一一对应的关系，封装处理数据的逻辑，对 View 提供处理数据的接口，View Modal 的生命周期一般比 View 长，保证了数据的安全。

{% notel blue Info %}
项目中 View 与 ViewModal 中通常还存在 **Repository** 中间类型，封装本地 SQL 与 云端 API 的交互，分担了 View Modal 处理数据的压力。
{% endnotel %}

下面用 [一张图](https://stackoverflow.com/questions/55316650/android-mvvm-update-viewmodel-when-data-changes) 展示 MVVM 架构各个部分的关系与职责：

![mvvm](mvvm.webp)

（这是 Android App 开发的规范，所以会有一些专有名词，比如 Activity 、 Fragment 、 LiveData ，而 Room 与 Retroft 是三方库。）

### React Native 的设计

一般的 React Native 项目习惯把数据与 UI 写在一个文件里，准确来说是让 UI 负责数据处理，甚至连官方提供的 demo [`StickerSmash`](https://docs.expo.dev/tutorial/create-your-first-app) 都是这样做的。

React.useState() 函数提供了可观测对象和一个修改函数，这也使得数据一旦需要显示，就必须与 UI 代码耦合。

在没有 MobX 的情况下，代码是这样的：

```typescript
import { useState } from "react";

export default function SomeScreen() {
  let [number, setNumber] = useState(0);

  return (
    <View>
      <TouchableOpacity onPress={() => setNumber(number + 1)}>
      <Text>{number}</Text>
    </View>
  );
}
```

功能很简单，点击按钮，数字加一。

我们假设当前的数字是从后端获取的，对数字加一的操作之后需要同步回后端，现在只要补全代码就行了：

```typescript
...
import { useState } from "react";

export default function SomeScreen() {
  let [number, setNumber] = useState(/* fetch from backend */);

  return (
    <View>
      <TouchableOpacity onPress={() => {
        setNumber(number + 1);
        <!-- upload to backend -->
      }}>
      <Text>{number}</Text>
    </View>
  );
}
```

这样乍一看没有什么问题，是实际上很可能会成为项目的癌症。随着功能不断增加， **SomeScreen** 的代码不断变长，各种数据处理、 API 交互等全部添加在这里，最后会变得难以维护。

## MobX 的引入

上述问题可能有其他的解决方法，但是本文不做讨论，只对 MobX 进行讲解。

MobX 可以创建可观测的对象，打破了 React Native 的限制，使得数据处理可以在 UI 代码之外存在。这个特性带来了在 React Native 中使用 MVVM 架构的可能性。

以下是使用 MobX 重构后的代码实现：

```typescript
// DataViewModal.ts
import { makeAutoObservable, runInAction } from "mobx";

class DataViewModal {
  // fields begin here
  private _data = 0;

  static Instance = new DataViewModel();

  private constructor() {
    makeAutoObservable(this);
    this.init();
  }

  private init = async () => {
    let data = await ...; // fetch from backend
    runInAction(() => {
      this._data = data;
    })
  }

  get data() {
    return this._data;
  }
  aync updateData() {
    this._data = data + 1;
    await ...; // upload to backend
  }
}

export default function useDataViewModel() {
  return DataViewModal.Instance;
}
```

```typescript
// SomeScreen.tsx

...
import useDataViewModel from "./DataViewModel";

export default function SomeScreen() {
  const dataViewModel = useDataViewModel();

  return (
    <View>
      <TouchableOpacity onPress={() => dataViewModel.updateData()}>
      <Text>{dataViewModel.data}</Text>
    </View>
  );
}
```

`makeAutoObservable` 函数告诉编译器，这个类是一个可观测对象， `runInAction` 函数用于保证可观测对象的更新。

看起来可能暂时复杂了，但是等到功能变多时，我们只需要增加更多的 Modal 和 ViewModal 就够了，是长久之计。

## 高级技巧

遇到复杂的场景时， MobX 也提供了一些函数，这里介绍一个最常用的函数 `reaction` 。

当一个可观测对象依赖其他变量时，可以用 reaction 函数观测变量是否变化。

示例代码如下：

```typescript
// DataViewModal.ts
import { makeAutoObservable, reaction, runInAction } from "mobx";
import useAnotherVieModel from "./AnotherVieModel"

class DataViewModal {
  ...

  private constructor() {
    makeAutoObservable(this);
    this.init();

    reaction(
      () => [useAnotherVieModel.anotherData],
      () => this.init(),
    );
  }

  ...
}

...
```

新增的 `reaction` 块分为两部分：

- 第一个 `()`：在回调中填写需要观测的量，可以是变量和函数（返回值）。

- 第二个 `()`：在任何观测的量发生变化时，执行回调区域的代码。

`reaction` 块可以存在 **多个** ，互相之间 **独立** ，一般写在 **构造函数** 内部。
