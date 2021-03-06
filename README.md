# Electron Netease Cloud Music

**UNOFFICAL** client for music.163.com

[![build status](https://api.travis-ci.org/Rocket1184/electron-netease-cloud-music.svg?branch=master)](https://travis-ci.org/Rocket1184/electron-netease-cloud-music/builds)
[![dependencies staus](https://david-dm.org/rocket1184/electron-netease-cloud-music/status.svg)](https://david-dm.org/rocket1184/electron-netease-cloud-music)
[![devDependencies staus](https://david-dm.org/rocket1184/electron-netease-cloud-music/dev-status.svg)](https://david-dm.org/rocket1184/electron-netease-cloud-music?type=dev)

## Download latest master/dev releases
Click here -> [![hreoku status](https://heroku-badge.herokuapp.com/?app=electron-ncm-downloads&style=flat&svg=1)](https://electron-ncm-downloads.herokuapp.com/) <-

## Features
 - [x] 用户登录（手机号/邮箱/用户名）
 - [x] 每日签到（可同时签到 PC 端和移动端）
 - [x] 播放用户收藏/创建的歌单以及每日歌曲推荐
 - [x] ~~高仿~~ 音乐播放界面，滚动歌词
 - [x] 喜欢音乐(加红心)
 - [x] 收藏音乐到歌单
 - [ ] 收藏歌单
 - [ ] 浏览/发布歌曲评论
 - [ ] 各种搜索

## ScreenShots

![音乐播放界面](https://images2015.cnblogs.com/blog/877509/201705/877509-20170501001930615-1255918997.png)

## Build Setup

``` bash
# install dependencies
yarn install

# serve with hot reload at localhost:24353
npm run dev

# build the app in production mode
export NODE_ENV=production
npm run pack
npm run build linux
npm run build darwin
```
