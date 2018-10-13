---
title: 右键添加在此处打开cygwin
categories:
- 备忘
- 技术
tags: 
- Cygwin
- Windows
---

系统：windows 10
目标：在空白处点击右键菜单，显示如图菜单项，点击后可以打开 cygwin 并切换到当前所在目录

![效果](https://img-blog.csdn.net/20180730221756934?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3l1aXN5dQ==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

方法一：
======

步骤：

1. 开始菜单运行 regedit 打开注册表
2. 定位到
    ```txt
    计算机\HKEY_CLASSES_ROOT\Directory\Background\shell\Cygwin\command
    ```
3. 新建项和字符串到如下图所示
    ![cygwin 菜单](https://img-blog.csdn.net/20180730222237404?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3l1aXN5dQ==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

    ![命令](https://img-blog.csdn.net/20180730221920537?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3l1aXN5dQ==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
4. 默认值填写
    ```bat
    C:\cygwin64\bin\mintty.exe -e /bin/bash --login -i -c "cd '%V';exec bash
    ```

方法二：
======

重新运行 cygwin 安装程序，勾选 chere 安装包。
安装完成后，使用管理员身份运行 cygwin。

```shell
chere -i -t mintty -s bash
```

此时右键菜单应该有 "Bash Prompt Here" 菜单选项。
Win10 系统中，更改此处注册表，
`计算机\HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\background\shell\cygwin64_bash`
增加 Icon 字符串，并更改中文描述，达到上图菜单效果。