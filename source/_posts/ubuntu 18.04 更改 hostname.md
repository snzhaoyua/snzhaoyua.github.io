---
title: ubuntu 18.04 更改 hostname
categories:  
- 备忘
- 技术
tags: 
- Ubuntu 18.04
- Linux
---

```shell
vi /etc/cloud/cloud.cfg
#preserve_hostname: false  ---> 改成 true
vi /etc/hostname
reboot
```