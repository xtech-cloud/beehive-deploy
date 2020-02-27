# 开发环境搭建

## Alpine Linux

`推荐使用Alpine v3.11`

可以选择以下几种方式：

- WSL

Windows Subsystem for Linux（简称WSL）是一个为在Windows 10上能够原生运行Linux二进制可执行文件（ELF格式）的兼容层。

使用WSL，在Windows上能更方便的进行BeeHive的开发。

在Windows应用商店搜索"Alpine"，安装完成后推荐安装Windows Terminal,方便打开多个linux shell。

在PowerShell中运行以下命令，默认以root账户登录Alpine
```bash
> Alpine.exe config --default-user root
```

打开/etc/apk/repositories,将源替换为阿里云
```bash
http://mirrors.aliyun.com/alpine/v3.10/main/
http://mirrors.aliyun.com/alpine/v3.10/community/
```

更新源
```bash
~# apk update
```

- Docker

对于整个XTechCloud使用的云端服务的开发，我们提供了一系列的工具及服务。具体可以在这里找到 https://github.com/xtech-cloud。

用于开发的镜像，使用了Alpine的3.11版本，使用很简单。

```bash
~# docker run --name=omo-devbox -v /var/share:/share -p 11000:22 -p 11001-11009:11001-11009 -p 11001-11009:11001-11009/udp -d xtechcloud/omo-devbox:3.11
```

/share卷用于和宿主机共享文件，你可以将它映射到需要的路径。

11001-11009端口用于将容器中的端口映射到宿主机中，你也可以按照实际需要进行更改。

更多细节可以参考 https://hub.docker.com/r/xtechcloud/omo-devbox

更改完密码后，就可以使用ssh连接容器了。

### 依赖库和工具

优先安装以下工具和库

```bash
~# apk add --no-cache sudo perl bash openssh ca-certificates curl alpine-sdk git vim 
```

### 编译工具

#### Go

- 安装

```bash
~# apk add go --no-cache --repository=https://mirrors.aliyun.com/alpine/v3.11/community/
```

- 配置GoProxy

在/etc/profile文件末尾添加一行
```bash
export GOPROXY="https://goproxy.io"
```

让配置立刻生效
```bash
~# source /etc/profile
```

### 功能服务

```bash
~# apk add redis --no-cache --repository=https://mirrors.aliyun.com/alpine/v3.11/main/
~# apk add mariadb --no-cache --repository=https://mirrors.aliyun.com/alpine/v3.11/main/
~# apk add consul --no-cache --repository=https://mirrors.aliyun.com/alpine/edge/testing/
```

