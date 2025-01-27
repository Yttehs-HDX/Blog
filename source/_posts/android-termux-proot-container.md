---
title: Android Termux Proot Container
date: 2025-01-27 14:44:38
tags: [Android, Termux, Container]
category: [Guide, Termux]
thumbnail: /image/android-termux-proot-container/head.webp
excerpt: Linux container on Android
---

## Before Reading

In this passage I will install Linux container on Android via Termux app.

And I will build a development environment:

- [x] Desktop
- [x] VNC login
- [x] VSCode

### Environment

Please note that the difference of **devices** and version of **Termux** may have unknown behaviours.

This is my environment:

| Device         | Android Version | Termux                | VNC App                 |
|:--------------:|:---------------:|:---------------------:|:-----------------------:|
| OnePlus Ace 3V | 15              | googleplay.2025.01.18 | RVNC Viewer 4.9.2.60169 |

{% notel blue Info %}
In this guide, `ArchLinux` is the example.
{% endnotel %}

### Errata

Before delving into the text, it's important to note that there may be some **grammar or syntax errors**  present. This could be due to translation errors, typing mistakes, or the author's unique writing style ( I'm a Chinese native speaker 😅 ).

## Install Proot Container

Open Termux app.

1. Update packages.

```bash
apt update && apt upgrade
```

2. Install packages.

```bash
apt install proot proot-distro
```

3. Download and install ArchLinux.

```bash
proot-distro install archlinux
```

4. Login to Linux distribution.

```bash
proot-distro login archlinux
```

5. (Optional) Use **fish** shell for better experience.

```bash
pacman -Syu
pacman -S fish
chsh -s $(which fish)
```

## Install VNC and Desktop on ArchLinux

> Make sure you have logged in ArchLinux.

1. Update system packages.

```bash
pacman -Syu
```

2. Install desktop and VNC.

```bash
pacman -S tigervnc xfce4
```

## Create New User

> Make sure you have logged in ArchLinux.

*Replace \<username\> with your username such as admin.*

1. Create a user.

```bash
useradd --create-home <username>
usermod -aG adm,storage,wheel <username>
```

2. Set **sudo** permission.

```bash
# install sudo if not exists
pacman -S sudo
```

```bash
visudo
# or use nano
EDITOR=nano visudo
```

At **User privilege specification**:

```conf
##
## User privilege specification
##
root ALL=(ALL:ALL) ALL
```

Add this line:

```conf
<username> ALL=(ALL:ALL) ALL
```

3. Set password for new user.

```bash
passwd <username>
```

4. Login as new user.

```bash
exit
proot-distro login archlinux --user <username>
```

## Install AUR Helper and VSCode

> Make sure you have logged in ArchLinux.

1. Add archLinuxcn source

Edit `/etc/pacman.conf`:

```bash
sudo vi /etc/pacman.conf
# or use nano
sudo nano /etc/pacman.conf
```

On the very bottom, add:

```conf
[archlinuxcn]
SigLevel = Optional TrustAll
Server = https://repo.archlinuxcn.org/$arch
```

Sync packages and add keyring:

```bash
sudo pacman -Syu archlinuxcn-keyring
```

Edit `/etc/pacman.conf`, remove this line:

```conf
SigLevel = Optional TrustAll
```

2. Install `yay` package.

```bash
sudo pacman -S yay
```

3. Install `VSCode` via yay.

```bash
yay -S visual-studio-code-bin
```

{% notel yellow Warn %}
Do **NOT** run `yay` with `sudo` to avoid safety problem.
{% endnotel %}

## Setup and Use VNC Server

1. Set VNC password.

```bash
vncpasswd
```

2. Start VNC server.

```bash
vncserver :0
```

3. Open VNC client app, login with url `localhost:5900` and password.

## Use VSCode

> In my device, VSCode can only run **WITHOUT** sandbox.

```bash
cd /path/to/project
code --no-sandbox .
```

## Enjoy

![final](final.jpg)
