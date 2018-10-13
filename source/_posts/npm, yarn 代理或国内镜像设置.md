---
title: npm, yarn 代理或国内镜像设置
categories:  
- 备忘
- 技术
tags: 
- npm
- yarn
---

使用家目录下的默认rc文件配置，不使用 npm config set.. 

npm 代理
```
vi ~/.npmrc
## add these lines to .npmrc
## privoxy and shadowsocks [如何配置 privoxy 详见另一篇博文]()
proxy=http://localhost:8118
https_proxy=https://localhost:8118
strict-ssl=false
```

npm 国内镜像-淘宝
```
registry=https://registry.npm.taobao.org
## proxy=http://localhost:8118
## https_proxy=https://localhost:8118
## strict-ssl=false
```

yarn 代理
```
vi ~/.yarnrc
## add these lines to .yarnrc
env:
    proxy 'http://localhost:8118'
    https_proxy 'https://localhost:8118'
    strict-ssl false
```

yarn 使用国内镜像
```
yarn config set registry https://registry.npm.taobao.org
yarn config list
```