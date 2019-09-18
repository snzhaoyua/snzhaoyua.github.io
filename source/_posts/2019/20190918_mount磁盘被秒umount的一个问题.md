----
title: mount 磁盘被秒 umount 的一个问题
categories:
- 备忘
- 技术
tags:
- systemd
----

== mount 磁盘被秒 umount 的一个问题
:stem: latexmath
:icons: font

=== 问题描述

在 ubuntu 18.04 的机器上（家用），自己搭了一个 samba 服务器。有一天要添加一块磁盘，因为服务器上还
运行了一些其他服务，不想重启，因此使用 partprobe 动态扫描了磁盘，分区，写入 /etc/fstab，一切正常。
执行 mount -a，没有任何报错，不过磁盘就是没有挂载上去。

=== 解决思路
1. 使用 mount 命令，可以手动挂载
2. 无任何报错出现，使用 umount 提示并未挂载

查看 journalctl -xe，发现是 systemd 在 umount 磁盘。最终还是搜索解决了问题，https://unix.stackexchange.com/questions/169909/systemd-keeps-unmounting-a-removable-drive 描述了这个问题。

执行 systemctl daemon-reload 解决后，重新 mount -a 解决。



