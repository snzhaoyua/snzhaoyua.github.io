---
title: Scala sbt 使用自定义的 maven 仓库
categories:  
- 备忘
- 技术
tags: 
- Scala
---

#### 1.编辑或新建 ${HOME}/.sbt/repositories，添加如下

```txt
[repositories]
local
any-name-you-want: 你的仓库地址
```

#### 2.编辑 ${sbt_安装目录}/conf/sbtconfig.txt，如果你使用的 idea，在 settings->SBT-> jvm parameters 添加

```txt
-Dsbt.override.build.repos=true ## 忽略工程自定义的 resolvers，采用全局配置
```

>参考 [sbt 代理仓库 设置](https://www.scala-sbt.org/1.x/docs/Proxy-Repositories.html)