---
title: 用软件工程的思维进行单片机编程
date: 2025-06-09 11:22:29
tags: [Guide, Embedded, CH32]
category: [Guide, Embedded]
thumbnail: image/software-engineer-micro-program/head.webp
excerpt: 软件开发者的单片机初体验
---

## 前言

头像来自 [ch32-rs](https://github.com/ch32-rs).

{% notel yellow Warn %}
本文**不是**新手入门教程，只是我的学习过程。
本文提及的任何开发版、库、工具与本人**无任何利益关系**，只作为分享。
文中包含了我个人的主观想法，**不一定**正确，请仔细甄别。
{% endnotel %}

### 起因

室友邀请我打嵌入式比赛，让我负责前端 app 部分，后来得知开发版可以从主办方免费申请，就抱着玩一玩的心态申请了一块 CH32V307VCT6。

![micro](micro.jpg)

### 勘误

在深入研究文本之前，请务必注意可能存在一些 **语法错误** ，这可能是由于翻译错误、打字错误或作者独特的写作风格。

如果你有疑问或者建议，欢迎在评论区留言，或通过邮箱 shetty@shettydev.com 联系。

## 开发板参数

CH32V307VCT6，属于 CH32 系列，它在设计上估计是模仿 STM32 的，只不过芯片架构是 riscv32。

| 名称         | 系列 | 架构    | 文档                                             |
|:------------:|:----:|:-------:|:------------------------------------------------:|
| CH32V307VCT6 | CH32 | riscv32 | [WCH](https://www.wch.cn/products/CH32V307.html) |

它有一个比同系列（CH32 系列）与众不同的地方：开发版分为两部分，主体和 W-Link ，W-Link 的功能是 USB-Serial 转换，一般的板子需要格外的转换器以及若干根杜邦线才能够进行刷写程序，由于 CH32V307VCT6 集成好了，所以只需要连接 USB 即可。

## 传统的编程方式

从官网找文档和示例代码无疑是学习的最好选择，不出所料，是经典的 C 语言。

{% notel blue Info %}
单片机的源码可以交叉编译为 ELF 文件，但是与普通程序不同，普通程序如果需要裸机（no_std）运行，必须裁剪符号成为二进制（bin）文件，而单片机烧录的文件是纯文本的 hex 文件。
某些类型的单片机，源码中会存在 C 语言中不存在的关键字，比如 8051 的 `code` 和 `interrupt` 关键字，严格意义上来说不算标准的 C 语言。
{% endnotel %}

### 示例代码

以下是初始化 GPIO 的源码：

```c
GPIO_InitTypeDef GPIO_InitStructure = {0};

RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
GPIO_Init(GPIOA, &GPIO_InitStructure);
```

> 本人不是很习惯 do_something(&type instance, params) 的方式用于表示一个实例做了一件事，更喜欢使用成员函数，instance.do_something(params)。
> 由于 C 语言的局限性，很多地方也只能这样做。
> 用一门语言，就遵循这门语言的规范。

值得一提的是，这个系列有优秀的日志功能 **SDI_Printf**，可以调用 printf 函数直接把日志打印到串口，在 PC 端直接查看：

```c
#if (SDI_PRINT == SDI_PR_OPEN)
    SDI_Printf_Enable();
#else
    USART_Printf_Init(115200);
#endif
    printf("SystemClk:%d\r\n", SystemCoreClock);
```

## 一种比较新的方式

### 背景

大名鼎鼎的 STM32 存在官方维护的 HAL 库，将硬件层抽象，为单片机编程人员提供接口。

[embassy](https://embassy.dev/) crate 提供了完善的抽象层，越来越多开源社区对各种开发板进行了适配，很多三方实现的 HAL 库纷纷问世，使用 rust 进行嵌入式开发成为潮流。

### 对比

传统单片机编程一般使用的是集成 IDE 或者祖传的 Keil，框架隐藏了编译所需的文件（比如 ld 脚本），隐藏了编译的复杂流程（C 语言 -> ELF -> hex），简而言之，开发者只能在对应的 IDE 中编程。

PlatformIO、Rust Embedded 提供了 CLI，完成单片机项目可以不用依赖具体的 IDE（这通常比较难用）。因此，开发者可以自由选择开发环境，将软件工程的有点移植到单片机开发中。

### ch32-hal

[ch32-hal](https://github.com/ch32-rs/ch32-hal) 是 [ch32-rs](https://github.com/ch32-rs) 组织的一个项目，为大部分 CH32 开发板提供了 HAL 的抽象层，使用 Rust（no_std）编写。

> 十分感谢开源社区提供了这么好用的库😋。

{% notel blue Info %}
Rust 是现代的高级语言，生态位最开始与 C、汇编相同，但是在今天已经涉及到各种领域：前端、后端、底层等。
Rust 的 cargo 包管理以及丰富的 crates 使得项目管理变得更加容易。
因此，在底层开发中运用 dev ops，也不是一件难事了，比如语法检查、AI 建议、CI/CD 自动构建。
{% endnotel %}

### 示例代码

初始化 GPIO，完全不用手写复杂的逻辑：

```rust
let p = hal::init(hal_config);
let mut led = Output::new(pin, Level::Low, Default::default());
```

如果想要设置引脚，也很简单，OOP 使得一切变得简洁与美观：

```rust
led.set_high();
led.set_low();
```

## 软件工程思维

软件工程充斥着面向对象和设计模式，开发者可以将相关功能封装成对象，让单片机开发变得与前端开发一样。

以下使用我的个人项目[CH32-ST7735-Demo](https://github.com/Yttehs-HDX/CH32-ST7735-Demo)举例：

这个项目简单使用了 ST7735 屏幕显示固定的图案，以下两处进行了封装：

### 控制显示

- [display_manager.rs](https://github.com/Yttehs-HDX/CH32-ST7735-Demo/blob/main/src/display_manager.rs)

```rust
fn new(dc: AnyPin, rst: AnyPin, cs: AnyPin, spi: Spi<'a, T, M>, display_rgb: bool, display_inverted: bool, display_width: u32, display_height: u32) -> Self
fn init(&mut self)
fn clear(&mut self, color: Rgb565)
fn set_orientation(&mut self, orientation: Orientation)
fn set_offset(&mut self, x: u16, y: u16)
fn draw_image(&mut self, image: &ImageRaw<Rgb565, LittleEndian>)
```

### 控制背光亮度

- [backlight_manager.rs](https://github.com/Yttehs-HDX/CH32-ST7735-Demo/blob/main/src/backlight_manager.rs)

```rust
fn new(pwm: SimplePwm<'a, T>, channel: Channel) -> Self
fn enable(&mut self)
fn set_brightness(&mut self, level: BrightnessLevel)
```

函数内部封装的可能是对引脚的直接操作，也有可能是对其他库函数的封装，当然，使用时根本不需要关心这些。

## 结语

使用第三方 HAL 库，embassy crate 进行单片机开发给我带来了极好的体验，但是这种方式并不适用于每一个人，因为涉及到了新的语言 Rust，和相关的 CLI 包管理工具 cargo。

企业、公司内部的单片机开发肯定不会冒风险使用第三方 HAL 库，如果生产环境中需要保证严格的安全性，就老老实实用官方库吧。
