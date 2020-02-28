# 开始使用

- [开发环境](#开发环境)
- [测试环境](#测试环境)
- [生产环境](#生产环境)


# 开发环境

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


# 测试环境

`本例使用Hyper-V`

## 网络配置

在Hyper-V中新建以下虚拟网络交换机。
`在Hyper-V中新建虚拟网络交换机后，系统会新建虚拟网卡，打开虚拟网卡的属性可以更改IP。`

|名称|类型|ip|mask|
|:--|:--|:--|:--|
|BeeHive-Private|内部|10.1.0.1|255.255.0.0|

打开连接外网的网卡的属性，将共享指定到BeeHive-Private网卡。以便虚拟机中能访问外网安装软件。
`共享连接后，虚拟网卡的IP就自动更改，需要手动再改回上表中的IP。`

## 系统配置

全部节点使用CentOS 7.7。相关设置设置参考下表。

|host|ip|mask|gateway|dns|
|:--|:--|:--|:--|:--|
|src-1|10.1.1.1|255.255.0.0|10.1.0.1|10.1.0.1|
|src-2|10.1.1.2|255.255.0.0|10.1.0.1|10.1.0.1|
|src-3|10.1.1.3|255.255.0.0|10.1.0.1|10.1.0.1|
|dsc-1|10.1.2.1|255.255.0.0|10.1.0.1|10.1.0.1|
|dsc-2|10.1.2.2|255.255.0.0|10.1.0.1|10.1.0.1|
|dsc-3|10.1.2.3|255.255.0.0|10.1.0.1|10.1.0.1|

src 指 Service Registry Center
dsc 指 Data Storage Center

- 防火墙

关闭
```
~# systemctl stop firewalld.service
```

禁用
```
~# systemctl disable firewalld.service
```

- 下载部署工具
```bash
~# cd ~
~# git clone https://github.com/xtech-cloud/beehive-deploy
~# mkdir -p ~/beehive-deploy/bin
```

- 下载Consul
```bash
~# cd ~
~# wget https://releases.hashicorp.com/consul/1.7.1/consul_1.7.1_linux_amd64.zip
~# unzip consul_1.7.1_linux_amd64.zip
~# cp consul ~/beehive-deploy/bin/
```

- 在SRC节点上部署服务端
```
~# cd ~/beehive-deploy
~# ./install-server.sh
```

- 在非SRC节点上部署客户端
```
~# cd ~/beehive-deploy
~# ./install-client.sh
```

- 重启
```
~# reboot
```

- 浏览
使用浏览器打开以下任何一个SRC的地址，都可打开UI
```
10.1.1.1:8500
10.1.1.2:8500
10.1.1.3:8500
```

## 测试

在http://10.1.1.1:8500/ui/dc1/kv中新建一个名为omo/msa/config/default.yaml的key，对应值的类型为YAML，内容为
```yaml
logger:
  level: 3
```

使用omo-msa-startkit开发套件作为测试服务，参照说明编译得到omo-msa-startkit

使用Windows Terminal打开3个Alpine Shell。分别执行以下命令：

- shell-1
```bash
~# export MSA_REGISTRY_PLUGIN=consul
~# export MSA_REGISTRY_ADDRESS=10.1.1.1:8500,10.1.1.2:8500,10.1.1.3:8500
~# export MSA_CONFIG_DEFINE='{"source":"consul", "prefix":"/omo/msa/config", "key":"default.yaml", "address":["10.1.1.1:8500", "10.1.1.2:8500", "10.1.1.3:8500"]}'
~# omo-msa-startkit
```

- shell-2
```bash
~# export MSA_REGISTRY_PLUGIN=consul
~# export MSA_REGISTRY_ADDRESS=10.1.1.2:8500,10.1.1.3:8500,10.1.1.1:8500
~# export MSA_CONFIG_DEFINE='{"source":"consul", "prefix":"/omo/msa/config", "key":"default.yaml", "address":["10.1.1.1:8500", "10.1.1.2:8500", "10.1.1.3:8500"]}'
~# omo-msa-startkit
```

- shell-3
```bash
~# export MSA_REGISTRY_PLUGIN=consul
~# export MSA_REGISTRY_ADDRESS=10.1.1.3:8500,10.1.1.1:8500,10.1.1.2:8500
~# export MSA_CONFIG_DEFINE='{"source":"consul", "prefix":"/omo/msa/config", "key":"default.yaml", "address":["10.1.1.1:8500", "10.1.1.2:8500", "10.1.1.3:8500"]}'
~# omo-msa-startkit
```

浏览http://10.1.1.2:8500/ui/dc1/services/omo.msa.startkit，不出意外的话，应该能看到以下内容

|ID|Node|
|:--|:--|
|omo.msa.startkit-...|src-1|
|omo.msa.startkit-...|src-2|
|omo.msa.startkit-...|src-3|

服务已经分别注册到了SRC上。

现在模拟客户端调用服务
```bash
~# micro call omo.msa.startkit StartKit.Call '{"name": "Bob"}'
```

留意3个shell中打印出的日志，被访问的服务会显示以下内容
```
 [Received StartKit.Call request]
```

多调用几次，可以看到3个服务会被随机访问。

现在把shell-1关掉，http://10.1.1.2:8500/ui/dc1/services/omo.msa.startkit中的服务会减少一个，在服务发现的方式下，客户端只需要知道SRC地址和服务提供的方法就可以，不需要关心服务在哪里，有多少实例。

# Product
