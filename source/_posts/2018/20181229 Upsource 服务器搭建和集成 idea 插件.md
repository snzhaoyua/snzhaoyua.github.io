---
title: Upsource 服务器搭建和集成 idea 插件
categories:
- 备忘
- 技术
tags: 
- code review
- Intellij Idea
- Upsource
---

【客户端安装、配置篇】
====
1. 安装 idea 插件 upsource
![image.png](http://rnd-isourceb.huawei.com/images/SZ/20181217/d204895d-7b94-4efc-84ff-159235e11510/image.png)
2. 重启 idea
3. 右下角有新增的 up 图标，点击之
![image.png](http://rnd-isourceb.huawei.com/images/SZ/20181217/671d58af-7fdc-453a-a7fa-bae3cdb4ff03/image.png)
4. 进行此步一定要记得先关闭 idea 的代理。
![image.png](http://rnd-isourceb.huawei.com/images/SZ/20181217/e28d8253-df71-4dbf-b91b-e879a9776b24/image.png)
填写 upsource 服务器地址，这个http://100.107.166.116:8080 是我自己搭的测试服务器，没有配 https（当前使用场景没什么必要），后面要是正式用，就换个服务器。
![image.png](http://rnd-isourceb.huawei.com/images/SZ/20181217/3e075f79-2731-42a8-ba80-8047cb8f021b/image.png)
5. 点击 ok
6. 在弹出的浏览器页面，输入账户和密码，第一次登陆会让你修改密码。测试账号（test01/Huawei@123）。账户找管理员申请（那个搭服务器的人）
    后期可以对接到w3账号。
7. 点击 login 后。idea 右下角 up 图标变量，说明插件可以使用了。
8. 点击图标 up，选择 rescan
![image.png](http://rnd-isourceb.huawei.com/images/SZ/20181217/9018ffa9-1e45-4671-9adb-f38a45a9d482/image.png)
9. 如果你的账号权限配置正确，那么你会搜索到你当前代码的工程。
![image.png](http://rnd-isourceb.huawei.com/images/SZ/20181217/b70747bc-a7a2-4ecc-9f84-d18d889d4cda/image.png)
否则，你会看到如下报错提示：
![image.png](http://rnd-isourceb.huawei.com/images/SZ/20181217/edf82633-2e88-41ae-8097-f1e7fcca46e3/image.png)

由于这个服务器目前只有mysql和rhm的代码，所以现在只可以进行它俩的cr。这个添加其他代码也很简单，是管理员要做的事情。

【使用】
====
网页篇不作赘述。只说插件。
1. 选择一个revision（提交），然后右键
![image.png](http://rnd-isourceb.huawei.com/images/SZ/20181217/ce748b54-6a64-4bad-aadb-d0ec46da28f2/image.png)
2. 选择 review changes，选择 create review。如果这个提交还没有 review，直接点击 ok，会创建一个新的 review（你需要管理员帮你赋权，否则只能查看不能创建 review）
3. 填写相关信息后，大家都可以看到你发起的 cr。效果如下：
![image.png](http://rnd-isourceb.huawei.com/images/SZ/20181217/eb1477b4-68a9-47d1-a809-6d3b28feae1c/image.png)


功能很多，可以发起疑问，可以讨论，可以接受和关闭 review。

【服务器篇】【管理员篇】TODO
====

搭建
----
这个看官网就行了，一般 code reviewer 看客户端就行。

管理
----

### 仓库添加
TODO
### 账号管理
1. 环境信息
管理地址
http://100.107.166.116:8080
管理员账号（创建账号和角色，添加仓库） admin/Km717070
2. 注意
免费版只支持10个用户，虽然upsource支持配置多个代码库，但是建议一个工程配置一个upsource服务器，切记。
3. 创建账号、赋权
TODO

