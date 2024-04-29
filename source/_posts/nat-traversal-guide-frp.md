---
title: NAT Traversal Guide - Frp
date: 2024-04-29 10:07:58
tags: [NAT Traversal,Frp, Guide]
---

## Before Reading

#### _Note: This is a guide on how to obtain ``ssh`` connection via NAT traversal._

### What's NAT Traversal

#### [fatedier/frp](https://github.com/fatedier/frp)

Map the port of the internal network device to the external network device.

Architecture ( From Github ):

![architecture](architecture.png)

### Errate

Before delving into the text, it's important to note that there may be some **grammar or syntax errors** present. This could be due to translation errors, typing mistakes, or the author's unique writing style ( I'm a Chinese native speaker 😅 ).

### Requirements

| Type   | Description                                          |
|--------|------------------------------------------------------|
| Server | a device or vps with a public IP and terminal access |
| Client | local device                                         |

- My environment:

| Type     | Server            | Client               |
|----------|-------------------|----------------------|
| Device   | Vps ( CentOS )    | Laptop ( ArchLinux ) |
| Platform | Linux             | Linux                |

## Download Frp Tools

#### [fatedier/frp Releases](https://github.com/fatedier/frp/releases)

1. Choose the latest version and the specific CPU architecture of the device.

Download at both server and client.

- If you are using ArchLinux:

For server:

```bash
sudo pacman -S frps
```

For client:

```bash
sudo pacman -S frpc
```

2. Extract the file

```bash
tar -xvf frp_x.x.x_<platform>_<architecture>.tar.gz
```

## Configure Toml File

Enter the unzipped folder.

```bash
cd /path/to/folder
```

### Server Configuration

```bash
vim frps.toml
```

- If you are using ArchLinux:

```bash
sudo vim /etc/frp/frps.toml
```

```toml
bindPort = 7000             # custom
```

### Client Configuration

```bash
vim frpc.toml
```

- If you are using ArchLinux:

```bash
sudo vim /etc/frp/frpc.toml
```

```toml
serverAddr = "host_name"    # replace host_name with the IP or domain of your server
serverPort = 7000           # same as bindport in frps.toml

[[proxies]]
name = "test-tcp"
type = "tcp"
localIP = "127.0.0.1"
localPort = 22
remotePort = 6000           # custom
```

## Start Frp

#### Start sshd service first.

```bash
sudo systemctl start sshd
```

### For Server

```bash
./frps -c frps.toml         # run
nohup ./frps -c frps.toml   # run on background
```

- If you are using ArchLinux:

```bash
sudo systemctl start frps
```

### For Client

```bash
./frpc -c frpc.toml         # run
nohup ./frpc -c frpc.toml   # run on background
```

- If you are using ArchLinux:

```bash
sudo systemctl start frpc
```

## Usage

In terminal of any device with Internet connection.

```bash
ssh -oPort=6000 <user_name>@<host_name>
# user_name from client
# host_name of server
```

## References

#### [Frp Offical Repository](https://github.com/fatedier/frp)
