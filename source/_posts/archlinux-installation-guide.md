---
title: ArchLinux Installation Guide
date: 2024-04-25 18:30:08
tags: [Linux, Arch, ArchLinux, Guide]
category: [Guide, Linux]
thumbnail: /image/archlinux-installation-guide/head.webp
excerpt: Install ArchLinux in your computer
---

## Before Reading

Head picture is the art work [滚挂的Arch](https://www.pixiv.net/artworks/113984765) by Glowing Bric@Pixiv.

### Why Use ArchLinux

- Just make a joke 🤣.

![image](why_use_archlinux.webp)

### Errata

Before delving into the text, it's important to note that there may be some **grammar or syntax errors**  present. This could be due to translation errors, typing mistakes, or the author's unique writing style ( I'm a Chinese native speaker 😅 ).

### Requirements

| Target   | Requirement            |
|----------|------------------------|
| Computer | UEFI booted            |
| You      | Knowledge of vim |

### Background

Having experienced multiple system crashes and reinstallations, it's time to record the steps of installation, this guide may include my custom configurations.

My computer: Asus Rog Strix G16

## Create a Boot Disk

### Download Boot Disk Maker

Download or install [``Ventoy``](https://www.ventoy.net/en/download.html), [``Rufus``](https://rufus.ie) ( Windows only ), [``balenaEtcher``](https://etcher.balena.io) or any other boot disk maker.

- I prefer using Ventoy due to its multiple iso support.

### Flash ArchLinux Installation Image

1. Download ArchLinux iso from [``Official``](https://archlinux.org/download) or [``tuna``](https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/latest) ( Recommended for Chinese users ).

2. Follow the guide of the specific tool, and make the disk ( Usually USB disk ) a boot disk with ArchLinux image.

- If you are using Ventoy, make your disk a Ventoy disk, and add the iso to boot disk.

## Set Hard Disk as ESP Partition

1. Before installation, be sure that the hard disk of computer is ESP partition.

2. If not, use [``DiskGenius``](https://www.diskgenius.com) or other tools.

3. [STFW](https://www.google.com) for more information.

#### _Note: Backup date before modify partitions._

## Configure BIOS Settings

1. Disable ``Fast Boot`` and ``Secure Boot``.

2. Select ``USB Device`` as the first startup item.

## Reboot Computer to Boot Disk

- If you are using Ventoy, boot ArchLinux iso.

Waiting the boot progress, then get a shell from ArchLinux installation image.

#### _Tips: Make use of **tab completion** from shell._

## Check Environment

```bash
ls /sys/firmware/efi/efivars
```

If no error occurs, it means the computer is UEFI booted.

Be sure the computer is UEFI booted, then continue.

## Connect to Network

- If your computer has connected to the network cable, skip the step.

1. Use iwd to connect wireless network.

```bash
iwctl
station wlan0 scan
station wlan0 get-networks
station wlan0 connect <wifi_ssid>   # specific Wifi SSID
# input password of Wifi
exit
```

2. Test the network.

```bash
ping archlinux.org -c 4
```

## Pacman Source

1. Stop ``reflector.service``, which will choose the fastest source.

```bash
systemctl stop reflector
```

2. Change pacman source ( Optional ).

```bash
vim /etc/pacman.d/mirrorlist
```

Add the following lines at the very top:

```
# tuna source
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
```

#### _Note: Remove sources from China after installation finished._

- Info: the source provider from China has the ability to upload the **IP and other information** of users who installed qv2ray ( For example ) to the government server.

## Sync Time

```bash
timedatectl set-ntp true
```

Check status

```bash
timedatectl status
```

## Partitioning

Check partitions

```bash
lsblk
```

1. Start partitioning.

| Common Mounting Points    |
|---------------------------|
| /                         |
| /boot ( Less than 1G )    |
| /home                     |
| swapfile ( Usually 5 GB ) |

Some partition related tools:

```bash
fdisk       # CLI partition tool
gdisk       # CLI partition tool
mkfs.ext4   # create an ext4 file system on a disk or partition
# example: mkfs.ext4 /dev/sda1
mkswap      # create a swap file system on a disk or partition
# example: mkswap /dev/sda2
```

- Do not know how to partition? [STFW](https://www.google.com) and RTFM.

2. Mounting partitions.

Assume this is the partition result:

| Device                      | Mounting Points |
|-----------------------------|-----------------|
| /dev/sda1 ( ESP partition ) | /boot/efi       |
| /dev/sda2                   | /               |
| /dev/sda3                   | /boot           |
| /dev/sda4                   | /home           |
| /dev/sda5                   | /opt            |
| /dev/sda6                   | swap            |

- In some disk, there is no sd, nvme0 instead.

```bash
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda3 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
mkdir /mnt/home
mount /dev/sda4 /mnt/home
mkdir /mnt/opt
mount /dev/sda5 /mnt/opt
swapon /dev/sda6
```

- If you accidentally mount the wrong partition:

```bash
umount /dev/sda<number>
# or
umount -R /mnt
```

3. Check the partition.

```bash
lsblk -f
```

## Install Basic System

### Install Basic Packages

- You may need to wait for a while.

```bash
pacstrap /mnt linux linux-headers linux-firmware base base-devel vim bash-completion iwd dhcpcd
```

- Or use my custom configuration:

```bash
pacstrap /mnt linux-zen linux-zen-headers linux-firmware base base-devel neovim fish iwd dhcpcd
```

### Install Keyring ( Optional )

```bash
pacstrap /mnt archlinux-keyring
```

### Generate Fstab

1. Generate /etc/fstab.

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

2. Check file.

```bash
cat /mnt/etc/fstab
```

- If you have made mistakes, return to the step [_Partitioning_](#Partitioning).

### Chroot

```bash
arch-chroot /mnt
```

#### _Tips: Use fish shell to enjoy the powerful auto-completion._

```bash
pacman -S fish  # install if not exits
fish && exit
```

### Grub

1. Install packages.

```bash
pacman -S grub efibootmgr efivar
```

2. Install grub.

```bash
grub-install /dev/sda1
grub-mkconfig -o /boot/grub/grub.cfg
```

### Enable Network Service

```bash
systemctl enable iwd dhcpcd
```

### Setup user root

1. Set password for root.

```bash
passwd root
```

2. Modify skel files.

```bash
vim /etc/skel/.bashrc
```

Add the following line at the very bottom:

```
export EDITOR='vim'
```

```bash
cp -a /etc/skel/. ~
```

### Exit Chroot Environment

```bash
exit
umount -R /mnt
reboot
```

### Connect to Network

Use [``iwctl``](#Connect-to-Network).

- If your computer has connected to the network cable, you may need:

```bash
pacman -S networkmanager
systemctl enable --now NetworkManager
```
### Setup Timezone

```bash
# example
timedatectl set-timezone Asia/Shanghai
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
timedatectl set-ntp true
```

### Setup Locale

```bash
vim /etc/locale.gen
```

Uncomment specific locales:

```
# example
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
```

```bash
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
```

### Setup Host

Setup host name.
 
```bash
vim /etc/hostname
```

```
# example
ROG-Strix-G16
```

Add loopback address in hosts.

```bash
vim /etc/hosts
```

Add the following lines at the very bottom:

```
127.0.0.1   localhost
::1         localhost
127.0.1.1   <hostname> <hostname>.localdomain
```

## Add User

1. Create user.

```bash
useradd --create-home <user_name>
passwd <user_name>
usermod -aG adm,wheel,storage <user_name>
```

2. Add sudo permission.

```bash
visudo
```

Uncomment the following line:

```
%wheel ALL=(ALL:ALL) ALL
```

## Add Pacman Source

```bash
vim /etc/pacman.conf
```

Uncomment the following lines:

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Add the following lines at the very bottom:

- You may use other source but remember the [Note](#Note-Remove-sources-from-China-after-installation-finished).

```
[archlinuxcn]
SigLevel = Optional TrustAll
Server = https://repo.archlinuxcn.org/$arch
```

Init archlinuxcn source.

```bash
pacman -Syyu
pacman -S archlinuxcn-keyring
```

Remove SigLevel = Optional TrustAll below [archlinuxcn]

```bash
vim /etc/pacman.conf
```

## Install Drivers

### Install GPU Drivers

Intel Drivers:

```bash
pacman -S intel-ucode mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver lib32-libva-intel-driver
```

AMD Drivers:

```bash
pacman -S amd-ucode mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau
```

### Install Nvidia Drivers ( Optional )

#### _Note: ``ArchWiki`` is better to guide [how to install Nvidia drivers](https://wiki.archlinux.org/title/NVIDIA)._

#### _Note: Backup before install._

```bash
# example
# install timeshift first
sudo timeshift --create
```

1. Install drivers.

If use kernel linux:

```bash
pacman -S nvidia
```

If use kernel linux-lts:

```bash
pacman -S nvidia-lts
```

Other kernels:

```bash
pacman -S nvidia-dkms
```

2. Install settings.

```bash
pacman -S nvidia-settings
```

3. Install prime ( Optional )

```bash
pacman -S nvidia-prime
```

4. Install VA-API implementation.

```bash
pacman -S libva-nvidia-driver
```

- If you are using laptop with both ``integrated graphics`` card and ``Nvidia graphic card``:

Reboot to Windows and adjust GPU settings to Optimus.

### Install Media Drivers

```bash
pacman -S alsa-utils alsa-plugins alsa-oss alsa-firmware alsa-ucm-conf
pacman -S sof-firmware
pacman -S pipeware pipeware-alsa pipeware-audio pipeware-pulse pipeware-jack
```

## Install KDE Plasma Desktop

- You may need to wait for a while.

1. Install fonts.

```bash
pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-emoji-blob noto-fonts-extra
```

2. Install plasma.

```bash
pacman -S plasma plasma-meta konsole dolphin kate ark gwenview vlc
```

3. Setup network.

```bash
systemctl enable sddm
systemctl disable iwd
pacman -S networkmanager
systemctl enable NetworkManager
```

## Enjoy

### 🎉🎉🎉 Congratulations! 🎉🎉🎉

Installation is over.

- Enjoy your own ``ArchLinux``.

```bash
reboot
```

### My Custom Linux Configurations

- Those are my personal configs, just modify them to suit your needs.

#### [zpacman](https://github.com/Yttehs-HDX/zpacman)

A simple, small omz plugin manager.

#### [Neovim-config](https://github.com/Yttehs-HDX/Neovim-config)

My custom neovim configuration.

#### [Tmux-config](https://github.com/Yttehs-HDX/Tmux-config)

My custom tmux configuration.

#### [Ranger-config](https://github.com/Yttehs-HDX/Ranger-config)

My custom ranger configuration.

#### [.bashrc](https://gist.github.com/Yttehs-HDX/093b22497f1a959ad02f2375e333bc3a)

My custom .bashrc.

## References

- [ArchWiki](https://wiki.archlinux.org/title/installation_guide)
