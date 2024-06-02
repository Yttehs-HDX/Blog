---
title: Android Kernel Building Guide
date: 2024-06-01 16:47:33
tags: [Guide, Android, Kernel, Linux]
category: [Guide, Android, Kernel]
thumbnail: /2024/06/01/android-kernel-building-guide/head.webp
expert: Building an Android Kernel
---

## Before Reading

Head picture is the art work [あんどろい子](https://www.pixiv.net/artworks/29919698) by mao@Pixiv.

### Errata

Before delving into the text, it's important to note that there may be some **grammar or syntax errors**  present. This could be due to translation errors, typing mistakes, or the author's unique writing style ( I'm a Chinese native speaker 😅 ).

## Environment

### Linux

Android kernel is a variant of Linux kernel, and due to the compilers and make tools, it's necessary to have a Linux shell environment.

Theoretically all forms of Linux are able to compile an Android kernel.

#### Example

WSL, VMware, Termux on Android, Physical machine

{% notel blue Info %}
In this guide, `Arch Linux` is used as the demonstration.
{% endnotel %}

My environment:

```bash
❯ neofetch
                   -`                    root@ROG-Strix-G16 
                  .o+`                   ------------------ 
                 `ooo/                   OS: Arch Linux x86_64 
                `+oooo:                  Host: ROG Strix G614JI_G614JI 1.0 
               `+oooooo:                 Kernel: 6.9.3-zen1-1-zen 
               -+oooooo+:                Uptime: 44 mins 
             `/:-:++oooo+:               Packages: 1312 (pacman), 6 (flatpak) 
            `/++++/+++++++:              Shell: bash 5.2.26 
           `/++++++++++++++:             Resolution: 2560x1600 
          `/+++ooooooooooooo/`           DE: KDE 
         ./ooosssso++osssssso+`          WM: KWin 
        .oossssso-````/ossssss+`         Theme: Adwaita [GTK2/3] 
       -osssssso.      :ssssssso.        Icons: Adwaita [GTK2/3] 
      :osssssss/        osssso+++.       Terminal: konsole 
     /ossssssss/        +ssssooo/-       CPU: 13th Gen Intel i9-13980HX (32) @ 5.400GHz 
   `/ossssso+/:-        -:/+osssso+-     GPU: Intel Raptor Lake-S UHD Graphics 
  `+sso+:-`                 `.-/+oso:    Memory: 6528MiB / 15602MiB 
 `++:.                           `-/+/
 .`                                 `/                           
```

{% notel blue Info %}
In this guide, we will build the following kernel.
{% endnotel %}

| Device  | Name      | Kernel Verison | Partition | GKI | Maintainer                                | Repository                                                                                |
|:-------:|:---------:|:--------------:|:---------:|:---:|:-----------------------------------------:|:-----------------------------------------------------------------------------------------:|
| polaris | MI MIX 2S | 4.9            | A only    | No  | [LineageOS](https://github.com/LineageOS) | [android_kernel_xiaomi_sdm845](https://github.com/LineageOS/android_kernel_xiaomi_sdm845) |

## Fetch Source Code

### Clone Kernel Source

```bash
mkdir kernel-sources
# set depth=1 to save storage
git clone https://github.com/LineageOS/android_kernel_xiaomi_sdm845 --depth=1
```

### Get Reliable Config (Optional)

Configs from kernel provider do not necessarily make the kernel run, even complie.

#### From Device

```bash
adb pull /proc/config.gz /tmp
cd /tmp
gzip -d config.gz
```

Move the config to the right place:

```bash
mv config /path/to/kernel/root/arch/arm64/config/polaris-stock_defconfig
```

## Preparing Toolchains

### Install Dependencies

{% tabs Package Manager %}
<!-- tab pacman -->
**Arch based Linux only**

```bash
sudo pacman -S clang gcc llvm bc bison base-devel ccache curl flex gcc-multilib git git-lfs gnupg gperf imagemagick lib32-readline lib32-zlib elfutils lz4 sdl openssl libxml2 lzop pngcrush rsync schedtool squashfs-tools libxslt zip zlib lib32-ncurses wxgtk3 ncurses inetutils cpio z3
```
<!-- endtab -->

<!-- tab AUR -->
**Different from the packages in tab `pacman`**

```bash
yay -S aosp-devel lineageos-devel
```
<!-- endtab -->
{% endtabs %}

### Clang (Cross platform)

[ZyCromerZ/Clang](https://github.com/ZyCromerZ/Clang/releases)

This is an example:

```bash
cd ..
mkdir -p toolchains/zyc-19
cd ./toolchains/zyc-19
wget https://github.com/ZyCromerZ/Clang/releases/download/19.0.0git-20240601-release/Clang-19.0.0git-20240601.tar.gz
tar -xzf Clang-19.0.0git-20240601.tar.gz -C zyc-19
```

## Write a Build Script

Building Android Kernel is a two-steps process:

1. Generate kernel config

```bash
make ARCH=<architecture> O=<output_dir> <config_name>
```

- `xxx_defconfig` is at kernel_root/arch/\<architecture\>/configs

2. Buide the kernel

Here is an build shell script example (From [my gist](https://gist.github.com/Yttehs-HDX/e90672dbb846a109c7173f9b8bdceebd#file-build-sh)):

```shell
#!/bin/bash

# kernel
DEFCONFIG="polaris-stock_defconfig" # replace with suitable config
O="out"
ARCH="arm64"

# clang
# .
# ├── kernel_root
# └── toolchains
CLANG_VERSION="19"
CLANG_PATH="$(pwd)/../toolchains/zyc-${CLANG_VERSION}"
PATH="$PATH:${CLANG_PATH}/bin"

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

# clean environment
echo -e "${YELLOW}-> make mrproper ...${RESET}"
rm -rf $O
make mrproper

# build kernel
echo -e "${YELLOW}-> make ${DEFCONFIG} ...${RESET}"
make O=$O ARCH=$ARCH $DEFCONFIG

echo -e "${BLUE}=> CLANG_PATH = ${CLANG_PATH}${RESET}"
echo -e "${YELLOW}-> make ...${RESET}"
make -j$(nproc --all) O=$O \
                      ARCH=$ARCH \
                      CC=clang \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi
```

Save as `build.sh` :

```bash
cd /path/to/kernel_root
vim build.sh
```

## Buiding

```bash
chmod +x build.sh
./build.sh
```

If succeed, the terminal output may similar to the following:

```bash
# Omit large amounts of output...
  GEN     .version
  LD      vmlinux.o
  MODPOST vmlinux.o
  CHK     include/generated/compile.h
  UPD     include/generated/compile.h
  CC      init/version.o
  LD      init/built-in.o
aarch64-linux-gnu-ld: warning: -z norelro ignored
aarch64-linux-gnu-ld: warning: .tmp_vmlinux1 has a LOAD segment with RWX permissions
  KSYM    .tmp_kallsyms1.o
aarch64-linux-gnu-ld: warning: -z norelro ignored
aarch64-linux-gnu-ld: warning: .tmp_vmlinux2 has a LOAD segment with RWX permissions
  KSYM    .tmp_kallsyms2.o
  LD      vmlinux
aarch64-linux-gnu-ld: warning: -z norelro ignored
aarch64-linux-gnu-ld: warning: vmlinux has a LOAD segment with RWX permissions
  SORTEX  vmlinux
  SYSMAP  System.map
  OBJCOPY arch/arm64/boot/Image
  DTC     arch/arm64/boot/dts/qcom/polaris-p3.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-p2-v2.1.dtb
  DTC     arch/arm64/boot/dts/qcom/sdm845-v2-mtp.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-mp-v2.1.dtb
  DTC     arch/arm64/boot/dts/qcom/sdm845-4k-panel-qrd.dtb
  DTC     arch/arm64/boot/dts/qcom/sdm845-mtp.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-p3-v2.1.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-mp.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-p1-v2.1.dtb
  DTC     arch/arm64/boot/dts/qcom/sdm845-rumi.dtb
  DTC     arch/arm64/boot/dts/qcom/sdm845-v2-qrd.dtb
  DTC     arch/arm64/boot/dts/qcom/sdm845-cdp.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-p2.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-p2-v2.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-p1.dtb
  DTC     arch/arm64/boot/dts/qcom/sdm845-v2-cdp.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-p1-v2.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-p3-v2.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-mp-v2.dtb
  DTC     arch/arm64/boot/dts/qcom/sdm845-4k-panel-cdp.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-p0.dtb
  DTC     arch/arm64/boot/dts/qcom/sdm845-v2-rumi.dtb
  DTC     arch/arm64/boot/dts/qcom/sdm845-sim.dtb
  DTC     arch/arm64/boot/dts/qcom/sdm845-4k-panel-mtp.dtb
  DTC     arch/arm64/boot/dts/qcom/polaris-p0-v2.dtb
  DTC     arch/arm64/boot/dts/qcom/sdm845-qrd.dtb
  Building modules, stage 2.
  GZIP    arch/arm64/boot/Image.gz
  MODPOST 0 modules
  CAT     arch/arm64/boot/Image.gz-dtb
```

{% notel blue Info %}
It may takes a very long time.
In my PC, it costs **2m 51s** .
{% endnotel %}

## Output Files

The kernel binary files is at `kernel_root/$O/arch/$ARCH/boot` .

Strongly recommend to enable
***Build a concatenated Image.gz/dtb by default*** (CONFIG_BUILD_ARM64_APPENDED_DTB_IMAGE=y)
***Appended DTB Kernel Image name (Image.gz-dtb)*** (IMG_GZ_DTB=y)
in config file

Output files may be:

- **Image**: kernel image
 
- **Image.gz**: kernel image

- **Image.gz-dtb**: kernel image

- **dtbo.img**: dtbo partition, relevant to fingerprint, refresh rate, etc.

## Package

### Clone AnyKernel3 Repo

### Write an Pakage Script

Choose one of Images ( `Image.gz-dtb` > `Image.gz` > `Image` ) and `dtbo.img` ( Optional, may result in bugs ) to package.

Here is a package shell script (From [my gist](https://gist.github.com/Yttehs-HDX/e90672dbb846a109c7173f9b8bdceebd#file-pack-sh)):

```shell
#!/bin/bash

VERSION_CODE="v1.0"
O="out"
FILES=("Image.gz-dtb") # choose suitable output files

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RESET='\033[0m'

# clone AnyKernel3
if ! [ -d AnyKernel3 ]; then
	echo -e "${YELLOW}=> Clone AnyKernel3 ...${RESET}"
	git clone https://github.com/osm0sis/AnyKernel3.git --depth=1
fi

# copy files
for file in $FILES; do
	cp $O/arch/arm64/boot/${file} AnyKernel3/
	echo -e "${YELLOW}-> Copy ${file}${RESET}"
done

# zip files
cd AnyKernel3/
zip -r9 "Kernel-polaris-lineageOS-${VERSION_CODE}-$(date +%Y-%m-%d-%H_%M).zip" * -x .git README.md LICENCE *.zip
```

The zip file is generated at `AnyKernel3/kernel-polaris-lineageOS-xxx.zip`

## Flash

Make sure you have third party recovery.

```bash
sudo pacman -S android-tools # install first if adb is not found
adb reboot recovery
```

#### ***Warning: Backup `boot.img` and `dtbo.img` before flash.***

On the device: choose adb sideload.

```bash
adb sideload <kernel_zip>
```

After the process, reboot.

## Afeterwords

If the kernel runs great, you can consider add features for it, such as `KernelSU`, `NetHunter`, `Docker`, `Lxc`, etc.

My work is at [`Yttehs-HDX/polaris_lineageOS_kernel`](https://github.com/Yttehs-HDX/polaris_lineageOS_kernel), having add KernelSU support.
