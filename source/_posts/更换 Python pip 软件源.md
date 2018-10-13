---
title: 更换 python pip 软件源
categories:  
- 备忘
- 技术
tags: 
- Python
- pip
---

```shell
mkdir ~/.pip
cd ~/.pip
touch pip.conf
## add these lines
[global]  
timeout = 6000  
index-url = https://pypi.doubanio.com/simple/  
[install]  
use-mirrors = true  
mirrors = https://pypi.doubanio.com/simple/
```

`pip install --upgrade pip`