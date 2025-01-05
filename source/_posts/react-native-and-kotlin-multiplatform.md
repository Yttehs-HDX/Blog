---
title: Comparison of React Native and Kotlin Multiplatform
date: 2024-12-30 11:00:39
tags: [Framework]
category: [Diary, Framework]
thumbnail: /image/react-native-and-kotlin-multiplatform/head.webp
excerpt: My feedback for React Native and Kotlin Multiplatform
---

## 前言

React Native 和 Kotlin Multiplatform 都是非常优秀的跨平台 App 开发框架。

{% notel blue Info %}
这里的 `跨平台` 指的是终端设备的操作系统，比如 Android、PC（Windows/Linux）、iOS 等，而不是架构层。
{% endnotel %}

## 实现原理

两者都使用 **声名式编程** 来定义 UI 组件，避免了传统 UI 层与组件分离的复杂性。

### Kotlin Multiplatform

- UI：Kotlin Multiplatform 使用 Kotlin 开发，JetBrains 默认提供了一系列完整的 Composable 组件，开发者可以轻松的定义自己 UI 界面。
- 底层实现：JetBrains 为 Kotlin 提供了 Native 编译（基于 LLVM），这意味着 Kotlin 可以编译为具体平台的机器码，在跨平台开发表现为：iOS/macOS 等苹果操作系统使用 Native 编译，在 Android/Desktop 使用 Jvm 编译。

### React Native

- UI：React Native 使用 JavaScript/TypeScript 开发，众所皆知： "JavaScript can do anything" ，而 TypeScript 是类型相对更安全的 JavaScript ，在 JSX/TSX 文件中，可以通过声明类 HTML 标签实现 UI 的编写。
- 底层实现：通过不同的运行时组件，JavaScript/TypeScript 代码可以在具体的平台运行，比如 iOS 的 JavaScriptCore 和 Android 的 Hermes。

---

## 对比

这里使用我开发的“电子木鱼”作为示例，这是一个简单的实现，使用的特性如下：

- MVVM 架构
- Sql 持久化
- 多平台支持（未测试 iOS）

> 仓库链接：[Kotlin Multiplatform](https://github.com/Yttehs-HDX/KMP-Counter)、[React Native](https://github.com/Yttehs-HDX/RN-Counter)

### 界面对比

| Kotlin Multiplatform                                                                              | React Native                                                                                          |
|---------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
| ![Android](https://raw.githubusercontent.com/Yttehs-HDX/KMP-Counter/main/docs/assets/android.png) | ![Android](https://raw.githubusercontent.com/Yttehs-HDX/RN-Counter/main/docs/assets/android-home.png) |
| Material-Design 风格，偏向于原生 Android 的 UI                                                    | 与网页前端一样由开发者自己定义                                                                        |

### 代码对比

对比数字按钮的 UI 实现。

- Kotlin Multiplatform

```kotlin
Button(
    modifier = Modifier
        .padding(64.dp),
    onClick = {
        numberViewModel.increaseNumber()
    },
) {
    Text(
        text = "$currentNumber",
        style = MaterialTheme.typography.headlineMedium,
    )
}
```

- React Native

```typescript
const NumberButton = (props: NumberButtonProps) => {
    return (
        <TouchableOpacity
            style={styles.secondaryContainer}
            onPress={props.onPress}>
            <Text style={styles.buttonText}>
                {props.num}
            </Text>
        </TouchableOpacity>
    );
};

const styles = StyleSheet.create({
    ...
    secondaryContainer: {
        backgroundColor: 'lightblue',
        padding: 30,
        borderRadius: 90,
        overflow: 'hidden',
    },
    buttonText: {
        fontSize: 30,
        fontWeight: 'bold',
    },
});
```

可以看出 Kotlin Multiplatform 使用 `@Composable` 函数定义 UI，React Native 使用 `HTML` 和 `CSS` 定义 UI。

虽然两者都是声名式定义，但是 Kotlin Multiplatform 更加精简。

### 具体平台交互对比

两者都使用 Platform-specific 文件，在编译时自动选择正确平台的实现。

- Kotlin Multiplatform

    - Button.kt：共享库使用 `expect` 关键字声明变量/函数/类。
    - Button.android.kt：特定库使用 `actual` 关键字实现变量/函数/类。
    - Button.ios.kt：特定库使用 `actual` 关键字实现变量/函数/类。

- React Native

    - Button.android.ts：特定文件定义变量/函数/类，公开的元素在所有 Platform-specific 文件中必须定义。
    - Button.ios.ts：特定文件定义变量/函数/类，公开的元素在所有 Platform-specific 文件中必须定义。

### 性能对比

- Kotlin Multiplatform

Kotlin 可以被编译为具体平台的原生构建产物，在 Android/Desktop 上表现为 class 字节码，在 iOS/macOS 上表现为二进制文件。

*性能较强，但是库开发/移植难度较大*

- React Native

在所有平台上都以 JIT 的方式运行 JavaScript/TypeScript 代码。

*性能较弱，但是库开发/移植难度较低*

## 关于未来的预测

Kotlin Multiplatform 是新兴产物，有 Google 与 JetBrains 的大力支持，发展快速，功能不亚于 React Native，现在只是生态还未完善。

React Native 目前市场应用广泛，在 Meta 的推动下，生态系统庞大，非原生使得开发简单但是也是性能瓶颈。

## 个人观点

我个人更加偏爱 Kotlin Multiplatform，并且相信在未来 Kotlin 的原生开发将会成为跨平台开发的亮点。

Kotlin Multiplatform 对于组件的定义脱离了对 HTML/XML 的依赖，更加简洁，使未学习前端的开发者也可以轻松上手；默认的 Material Design 组件更加漂亮，而且节省了开发者自定义组件的时间。

## 2025.1.5 附加

最近接触到了 React Native 的 expo 框架，它有很大的优势。

1. 生态系统完善，以 expo 开头的第三方库可以在多个平台上工作，并且只需要编写一份通用的代码。

2. 做了一层新的抽象，避免与 Android/iOS/Web 等平台的直接交互。

3. 生态系统完善，以 expo 开头的第三方库可以在多个平台上工作，并且只需要编写一份通用的代码。

