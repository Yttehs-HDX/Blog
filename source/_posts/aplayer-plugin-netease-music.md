---
title: APlayer 插件播放网易云音乐
date: 2025-07-17 21:04:53
tags: [Guide, APlayer]
category: [Guide, APlayer]
thumbnail: /image/aplayer-plugin-netease-music/head.webp
excerpt: 使用 APlayer 播放网易云音乐
---

## 前言

### 什么是 APlayer？

[APlayer](https://github.com/DIYgod/APlayer) 是一个 HTML5 播放器，很多前端项目都集成了 APlayer 用于播放音乐。

### 起因

我的博客使用了 [hexo-theme-redefine](https://redefine-docs.ohevan.com/zh/getting-started) 主题，恰好支持 APlayer 插件，所以想要放几首喜欢的音乐。

网易云音乐的音乐源丰富，我也是网易云的用户，理所当然使用它作为音乐源。

### 勘误

在深入研究文本之前，请务必注意可能存在一些 **语法错误** ，这可能是由于翻译错误、打字错误或作者独特的写作风格。

如果你有疑问或者建议，欢迎在评论区留言，或通过邮箱 shetty@shettydev.com 联系。

## APlayer 配置

以下是 hexo-theme-redefine 主题的 APlayer 配置部分：

```yaml
# Aplayer. See https://github.com/DIYgod/APlayer
aplayer:
  enable: true # Whether to enable
  type: fixed # fixed, mini
  audios:
    - name: # audio name
      artist: # audio artist
      url: # audio url
      cover: # audio cover url
      lrc: # audio cover lrc
      # .... you can add more audios here
```

### 歌曲名和作家

对于 `name` 和 `artist` 项，使用字符串即可。

### 歌曲 URL

指的是歌曲源文件，通常为 mp3 格式。

对于网易云音乐，访问歌曲主页网站（这里以「深藍」举例）：

![music-profile](music-profile.webp)

观察此时的 URL：

```txt
https://music.163.com/#/song?id=22724676
```

此时网站的 URL 中存在 `id` 参数，把它记录下来。

使用以下的 URL 获取歌曲源文件：

```yaml
# 将 ${id} 替换为刚刚获取的 id
url: https://music.163.com/song/media/outer/url?id=${id}.mp3
```

## 歌曲封面

访问以下 URL：

```bash
# 将 ${id} 替换为刚刚获取的 id
curl -T 'GET' 'https://music.163.com/api/song/detail/?id=${id}&ids=%5B${id}%5D'
```

得到了如下的输出：

```json
{
  "songs": [
    {
      "name": "深藍",
      "id": 22724676,
      ...
      "artists": [
        {
          ...
          "picUrl": "https://p1.music.126.net/6y-UleORITEDbvrOLV0Q8A==/5639395138885805.jpg",
          "img1v1Url": "https://p1.music.126.net/6y-UleORITEDbvrOLV0Q8A==/5639395138885805.jpg",
          ...
        }
      ],
      "album": {
        ...
        "blurPicUrl": "https://p1.music.126.net/kprSJv0yHoiwyJ7pbuEVxg==/834529325505669.jpg",
        "picUrl": "https://p1.music.126.net/kprSJv0yHoiwyJ7pbuEVxg==/834529325505669.jpg",
        ...
      },
      ...
    }
  ]
}
```

在这几个 URL 中选择一个可以正常显示的，作为 `cover`：

```yaml
cover: https://p2.music.126.net/kprSJv0yHoiwyJ7pbuEVxg==/834529325505669.jpg
```

## 歌曲歌词

{% notel blue Info %}
歌词是最麻烦的一部分
{% endnotel %}

访问以下 URL：

```bash
# 将 ${id} 替换为刚刚获取的 id
curl -T 'GET' 'https://music.163.com/api/song/lyric?id=22724676&lv=1&kv=1&tv=-1'
```

得到以下输出：

```json
{
  "sgc": false,
  "sfy": true,
  "qfy": true,
  "lrc": {
    "version": 16,
    "lyric": "[00:01.230]ah あなただけ 見つからないから 『啊 唯独寻觅不见你的踪影』\n[00:06.180]この目に映る世界は まるで嘘みたいに 『映于眼底的世界 亦如谎言般』\n[00:12.540]明日も廻り続けるの 『日复一日地轮转』\n[00:17.290]私だけを置き去りにして 『唯独我被抛弃』\n[00:25.570]\n[00:48.130]少しずつ 近づいてくるの 『渐渐临近』\n[00:52.830]風が冷えてきたら 夜が来るわ 『风带来寒意之时 夜便来临』\n[00:58.690]時間なら いくらでもあるから 『我有挥霍不完的时间』\n[01:03.820]果てのない手紙をあなたに書こう 『于是乎 决意为你执笔书写一封没有尽头的信』\n[01:08.660]\n[01:09.690]激しい雨とか降ってくれたら 『如若暴雨倾盆而至』\n[01:14.500]何かが記憶さえ隠し去ってくれるのなら 『是否能有些什么为我遮蔽这记忆』\n[01:27.940]\n[01:28.520]あなただけ 見つからないから 『啊 唯独寻觅不见你的踪影』\n[01:33.510]この目に映る世界は まるで嘘みたいに 『映于眼底的世界 亦如谎言般』\n[01:39.730]明日も廻り続けるの 『日复一日地轮转』\n[01:44.770]私だけを置き去りにして 『唯独我被抛弃』\n[01:56.930]\n[02:04.680]窓越しに 見える電車の 『透过窗户 只见电车的』\n[02:09.310]明かりは流星みたい 駆け抜けてく 『流光恍若流星 疾驰而过』\n[02:15.320]行き場のない夢物語 『不知去向的梦』\n[02:19.750]かなわないと知っても 願ってしまう 『纵然深知无法实现 亦禁不住期许』\n[02:25.340]\n[02:25.950]どこまで悲しみに染まったら 『到底要经历悲伤的几许浸染』\n[02:31.620]冷たい現実に この胸は震えなくなるの 『这心才不会因冰冷的事实而战栗』\n[02:44.740]\n[02:45.260]あなただけ 見つけられなくて 『唯独你 我遍寻不着』\n[02:49.640]切なさの波に ただ削られていく 『悲伤的浪潮 将我侵蚀』\n[02:56.010]深くて 光は射さない 『深不见底 亦暗不见光』\n[03:01.380]私だけを置き去りにして 『唯独我被抛弃』\n[03:09.640]\n[03:41.710]ah あなただけ 見つからないから 『啊 唯独寻觅不见你的踪影』\n[03:46.680]この目に映る世界は まるで嘘みたいに 『映于眼底的世界 亦如谎言般』\n[03:53.400]明日も廻り続けるの 『日复一日地轮转』\n[03:58.520]私だけを置き去りにして 『唯独我被抛弃』\n[04:03.220]\n[04:03.660]ah あなただけ 見つけられなくて 『唯独你 我遍寻不着』\n[04:08.450]切なさの波に ただ削られてゆく 『悲伤的浪潮 将我侵蚀』\n[04:14.920]深くて 光は射さない 『深不见底 亦暗不见光』\n[04:20.120]私だけを置き去りにして 『唯独我被抛弃』\n"
  },
  "klyric": {
    "version": 0,
    "lyric": ""
  },
  "tlyric": {
    "version": 0,
    "lyric": ""
  },
  "code": 200
}
```

复制 JSON 的 `lrc.lyric` 部分，将 `\n` 替换为换行，保存为一个 lrc 文件（比如 22724676.lrc）：

{% notel blue Info %}
一定要替换 `\n` 为普通换行，否则歌词无法识别。
{% endnotel %}

```lyric
[00:01.230]ah あなただけ 見つからないから 『啊 唯独寻觅不见你的踪影』
[00:06.180]この目に映る世界は まるで嘘みたいに 『映于眼底的世界 亦如谎言般』
[00:12.540]明日も廻り続けるの 『日复一日地轮转』
[00:17.290]私だけを置き去りにして 『唯独我被抛弃』
[00:25.570]
[00:48.130]少しずつ 近づいてくるの 『渐渐临近』
[00:52.830]風が冷えてきたら 夜が来るわ 『风带来寒意之时 夜便来临』
[00:58.690]時間なら いくらでもあるから 『我有挥霍不完的时间』
[01:03.820]果てのない手紙をあなたに書こう 『于是乎 决意为你执笔书写一封没有尽头的信』
[01:08.660]
...
```

将这个文件上传至 GitHub Gist 中，并复制 raw 文件链接：

```txt
https://gist.githubusercontent.com/Yttehs-HDX/6f133b5a8f35475404e1c581f3045b4a/raw/80a621dc3efdfdaa5bb161ce705904bf4d8080b0/22724676.lrc
```

添加到配置文件中：

```yaml
lyric: https://gist.githubusercontent.com/Yttehs-HDX/6f133b5a8f35475404e1c581f3045b4a/raw/80a621dc3efdfdaa5bb161ce705904bf4d8080b0/22724676.lrc
```

---

## 效果展示

此时配置已完成：

```yaml
# Aplayer. See https://github.com/DIYgod/APlayer
aplayer:
  enable: true # Whether to enable
  type: fixed # fixed, mini
  audios:
    - name: 深藍
      artist: ルルティア
      url: https://music.163.com/song/media/outer/url?id=22724676.mp3
      cover: https://p2.music.126.net/kprSJv0yHoiwyJ7pbuEVxg==/834529325505669.jpg
      lrc: https://gist.githubusercontent.com/Yttehs-HDX/6f133b5a8f35475404e1c581f3045b4a/raw/80a621dc3efdfdaa5bb161ce705904bf4d8080b0/22724676.lrc
```

![display](display.webp)
