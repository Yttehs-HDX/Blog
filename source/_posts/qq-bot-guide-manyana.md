---
title: QQ Bot Guide - Manyana
date: 2024-08-30 15:29:55
tags: [Guide, QQ, Bot]
category: [Guide, Bot]
thumbnail: /image/qq-bot-guide-manyana/head.webp
excerpt: Building a bot server
---

## Before Reading

Head picture is from repository [avilliai/Manyana](https://github.com/avilliai/Manyana).

### What's Manyana bot

Refer to: [avilliai/Manyana](https://github.com/avilliai/Manyana). The official tutorial is very detailed.

### Errata

Before delving into the text, it's important to note that there may be some **grammar or syntax errors**  present. This could be due to translation errors, typing mistakes, or the author's unique writing style ( I'm a Chinese native speaker 😅 ).

{% notel blue Info %}
Considering the detail and timeliness of the `official tutorial`, this passage will focus on the **important operations**.
{% endnotel %}

## Build Steps

### Install

```bash
wget https://gitee.com/laixi_lingdun/Manyana_deploy/raw/main/install.sh
chmod 777 install.sh
./install.sh
```

### Setup

In the installation directory:

```bash
bash ./start/gui.sh
```

Entering needed information, then run the top 3 servers.

Now the bot is booted.

## FAQ

#### Q: Error when logging:

```
qq: error while loading shared libraries: libatspi.so.0: cannot open shared object file: No such file or directory
```

#### A: Install apt package `libatspi2.0-dev`(pre-release source), you may need add

```
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-proposed main restricted universe multiverse
```

#### at `/etc/apt/sources.list` first.
