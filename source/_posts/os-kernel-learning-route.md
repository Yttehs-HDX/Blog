---
title: 操作系统（OS）内核学习路线
date: 2024-06-02 23:44:19
tags: [OS, Guide]
category: [Guide, OS]
expert: 操作系统 OS 内核赛道零基础学习路线
---

## 前言

大一刚到学校的我还是一枚萌新，连 git 都不能熟练使用，只会安装 Linux ，在 ACM 摸鱼了大半年发现水平根本比不过别人，于是来到龙芯实验室准备参加 OS 内核实现赛道。

后来有幸组建了 3 人队伍，在初赛通过了全部的测试样例，故写博客记录开发的过程，将其整理为学习路线，为社区贡献自己的微薄之力。

本文并不会深入讲解操作系统相关知识，以列举相关链接为主~，因为真要我讲我也讲不好~。

如有侵权，请联系删除。

## 勘误

在深入研究文本之前，请务必注意可能存在一些 **语法错误** ，这可能是由于翻译错误、打字错误或作者独特的写作风格。

如果你有疑问或者建议，欢迎通过邮箱 shetty.yttehs@outlook.com 联系。

下面开始正文部分。

---

## 比赛说明

选择 `RISC-V` 或 `Loongson` 架构之一进行内核开发。

{% notel yellow Warning %}
作者所在的团队选择了 `RISC-V` 架构，以下部分只包含 `RISCV` 架构。
{% endnotel %}

### 初赛

能够使用 `qemu-system-riscv64` 运行内核，并尽可能通过测试样例。

### 决赛

内核能够在真正的开发板上运行，并尽可能通过测试样例。

## 编程语言选择

*选择适合自己的，而不是最优的。*

### C 语言

  - 优点：语法相对简单，容易上手。

  - 缺点：安全性低，模块管理较为复杂。

#### C 语言入门相关资料

1. [菜鸟教程](https://www.runoob.com/cprogramming/c-tutorial.html): 真神。

### Rust

Rust 是一门现代化语言，微软、谷歌是 Rust 的支持者之一，他们在项目中也逐渐引入 Rust 来取代 C/C++ 。

  - 优点：模块化结构清晰，三方库资源丰富，安全性高，性能强。

  - 缺点：语法相对复杂，学习成本高。

{% notel blue Info %}
作者所在的团队选择了 `Rust` ，因此教程可能更多偏向于 Rust 语言。
{% endnotel %}

#### Rust 入门相关资料

1. [菜鸟教程](https://www.runoob.com/rust/rust-tutorial.html): 真神。

2. [Rustlings](https://github.com/rust-lang/rustlings): Rust 习题练习，根据自己的体质来。

3. [Rust 死灵书](https://nomicon.purewhite.io): 使用 Unsafe Rust 编程，根据自己的体质来。

## 开发环境搭建

### Linux

在 x86_64 的 PC 上编译 RISC-V 架构的内核需要 **交叉编译工具链（Cross-platform Toolchain）** 以及其他工具的支持，毫无疑问， Linux 提供了良好的支持。

为了得到 Linux 环境，有以下几种方式：

| 方式 | WSL 2                                            | VMware                   | 实体机                     | Termux on Android（不推荐） |
|:----:|--------------------------------------------------|--------------------------|----------------------------|-----------------------------|
| 优点 | 方便，轻量                                       | 接近实体机，有图形化界面 | 性能高                     | 可以在 Android 设备使用     |
| 缺点 | 环境隔离不彻底，没有图形化界面（其实可以用 VNC） | 开销大，配置繁琐         | 安装复杂，容易不小心丢数据 | arm64 架构的软件包少        |
| 难度 | ⭐                                               | ⭐⭐                     | ⭐⭐⭐⭐                   | ⭐⭐⭐⭐                    |

### 工具链

由于每个人的 Linux 环境不同，这时你意识到你要 [`STFW`](https://www.google.com) 了。

{% notel blue Info %}
后续也会有 **类似的问题** ，本文只给出一种或几种方案。
请视自身开发环境进行取舍，最终给你答案的还是 `STFW` 。
{% endnotel %}

{% tabs 编程语言 %}
<!-- tab C 语言 -->
关键词：`riscv`, `gcc`
<!-- endtab -->

<!-- tab Rust -->
关键词：`riscv`, `gcc`, `rustup`, `cargo`

对于 Rust ，[此教程](https://rcore-os.cn/rCore-Tutorial-Book-v3/chapter0/5setup-devel-env.html)有详细的说明。
<!-- endtab -->
{% endtabs %}

### 安装 QEMU

1. [rCore-Tutorial-Book-v3](https://rcore-os.cn/rCore-Tutorial-Book-v3/chapter0/5setup-devel-env.html#qemu)

## 前置知识

{% notel yellow Warning %}
也许你认为可以跳过这部分，不过现在偷的懒以后都会找回来的。
{% endnotel %}

{% notel blue Info %}
对于初学者，暂时学会基本的功能就够了，后续可以再次深入学习。
**跳读法** 未必不是一种好办法。
{% endnotel %}

### Break the Wall

*🤫嘘，小声说话，成为一名合格的 CSer 。*

请自行完成 [CS 自学指南](https://csdiy.wiki) 必学工具的第一项。

#### 目标

写项目中遇到困难时，会 `STFW` ，会 `Ask GPT for Help` 。

### Linux Shell

*这将促进 GUI 向 CLI 的转变。*

#### 目标

- 理解 `可执行文件` 的概念

- 使用命令行管理文件的创建/删除/移动

#### 进阶（选做）

- 打造属于自己的 shell

  由于 `bash` 的功能简陋，你可以使用以下列举的 shell ：

| shell | [fish](https://fishshell.com/)      | [zsh](https://ohmyz.sh/#install)      |
|:-----:|-------------------------------------|---------------------------------------|
| 优点  | 上手简单，内置插件丰富              | 需要自己动手配置，兼容传统 shell 语法 |
| 缺点  | 配置复杂，不完全兼容传统 shell 语法 | 社区支持度高，三方插件丰富            |

### Vim

*CLI 文本编辑器，Linux用户心目中神一般的存在。*

{% notel blue Info %}
🥹：如果我实在接受不了 Vim 怎么办？
CLI 编辑器不止 Vim ，可以用 `Nano`，`Emacs` 代替，更加适合新手。
{% endnotel %}

#### 目标

- 学会使用 Vim 编辑文件，学会基本的操作

#### 进阶（选做）

- 使用 `NeoVim`

*NeoVim 是更加强大的 Vim ，如果你不满足简陋的 Vim ，欢迎入坑 NeoVim 。*

NeoVim 有丰富三方插件，社区支持度高，打造成功可以与 VSCode 相媲美，不过配置过程较为繁琐，建议从使用别人的配置开始。

### Git

*强大的版本控制工具，CSer 必学。* 

### Makefile

*自动化编译和构建项目。*

{% notel yellow Warning %}
Makefile 内容较多，学习难度较高，建议对着模板改。
{% endnotel %}

#### 目标

- 使用 make 命令编译运行内核项目

### 相关资料

1. [Makefile Tutorial](https://makefiletutorial.com): Makefile 零基础入门，根据自己的体质来。

2. [NJU ProjectN](https://nju-projectn.github.io/ics-pa-gitbook/ics2024/PA0.html): 南京大学操作系统讲义的 PA0 部分，作为入坑 CLI 的参考。


