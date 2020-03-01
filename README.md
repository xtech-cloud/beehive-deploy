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

|缩写|含义|
|:--|:--|
|src|Service Registry Center|
|dsc|Data Storage Center|
|msa|Micro Service Agent|
|bla|Business Logic Agent|

|host|ip|mask|gateway|dns|
|:--|:--|:--|:--|:--|
|src-1|10.1.1.1|255.255.0.0|10.1.0.1|10.1.0.1|
|src-2|10.1.1.2|255.255.0.0|10.1.0.1|10.1.0.1|
|src-3|10.1.1.3|255.255.0.0|10.1.0.1|10.1.0.1|
|dsc-1|10.1.2.1|255.255.0.0|10.1.0.1|10.1.0.1|
|dsc-2|10.1.2.2|255.255.0.0|10.1.0.1|10.1.0.1|
|dsc-3|10.1.2.3|255.255.0.0|10.1.0.1|10.1.0.1|
|msa-1|10.1.100.1|255.255.0.0|10.1.0.1|10.1.0.1|
|msa-2|10.1.100.2|255.255.0.0|10.1.0.1|10.1.0.1|
|msa-3|10.1.100.3|255.255.0.0|10.1.0.1|10.1.0.1|
|bla-1|10.1.200.1|255.255.0.0|10.1.0.1|10.1.0.1|
|bla-2|10.1.200.2|255.255.0.0|10.1.0.1|10.1.0.1|
|bla-3|10.1.200.3|255.255.0.0|10.1.0.1|10.1.0.1|


在每个节点上依次执行以下操作：

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
    ~# yum install -y git
    ~# git clone https://github.com/xtech-cloud/beehive-deploy
    ~# mkdir -p ~/beehive-deploy/bin
    ```

- 下载Consul

    ```bash
    ~# cd ~
    ~# yum install wget -y
    ~# wget https://releases.hashicorp.com/consul/1.7.1/consul_1.7.1_linux_amd64.zip
    ~# unzip consul_1.7.1_linux_amd64.zip
    ~# cp consul ~/beehive-deploy/bin/
    ```

    如果下载速度很慢，而且其中一个节点已经安装成功的话，可以直接拷贝。
    ```bash
    ~# scp root@10.1.1.1:/usr/local/bin/consul ~/beehive-deploy/bin/
    ```

- 下载etcd
    `如果只使用Consul作为服务发现，可忽略此步骤`
    ```bash
    ~# cd ~
    ~# yum install wget -y
    ~# wget https://storage.googleapis.com/etcd/v3.4.4/etcd-v3.4.4-linux-amd64.tar.gz
    ~# tar -zxf etcd-v3.4.4-linux_amd64.tar.gz
    ~# cp ./etcd-v3.4.4-linux_amd64/etcd ~/beehive-deploy/bin/
    ~# cp ./etcd-v3.4.4-linux_amd64/etcdctl ~/beehive-deploy/bin/
    ```

- 安装服务发现

    - SRC-1

        ```
        ~# cd ~/beehive-deploy
        ~# ./install-server.sh
        ```

        修改/etc/consul.d/server.hcl
        ```bash
        node_name = "src-1"
        bootstrap_expect = 3
        bind_addr = "10.1.1.1"
        client_addr = "0.0.0.0"
        server = true
        ui = true
        ```

    - SRC-2

        ```
        ~# cd ~/beehive-deploy
        ~# ./install-server.sh
        ```

        修改/etc/consul.d/server.hcl
        ```bash
        node_name = "src-2"
        bootstrap_expect = 3
        bind_addr = "10.1.1.2"
        client_addr = "0.0.0.0"
        server = true
        ui = true
        ```

    - SRC-3

        ```
        ~# cd ~/beehive-deploy
        ~# ./install-server.sh
        ```

        修改/etc/consul.d/server.hcl
        ```bash
        node_name = "src-3"
        bootstrap_expect = 3
        bind_addr = "10.1.1.3"
        client_addr = "0.0.0.0"
        server = true
        ui = true
        ```

    `-bootstrap-expect参数说明：集群中最小仲裁服务器需要满足（N / 2）+1 才能正常工作。`

    |Servers|Quorum Size|Failure Tolerance|
    |:--|:--|:--|
    |1| 1|  0|
    |2| 2|  0|
    |3| 2|  1|
    |4| 3|  1|
    |5| 3|  2|
    |6| 4|  2|
    |7| 4|  3|

    `在单个服务器群集中出现不可恢复的服务器故障并且没有备份过程的情况下，由于没有将数据复制到任何其他服务器，因此数据丢失不可避免。所以不建议部署单个服务器的集群。`

    在任何一个SRC执行以下命令生成密钥
    ```bash
    ~# consul keygen
    ```
    打开每个SRC上的/etc/consul.d/consul.hcl，将密钥替换encrypt参数。
    `仔细检查，务必保证所有SRC节点的密钥保持一致。`

    - DCS-1

        ```
        ~# cd ~/beehive-deploy
        ~# ./install-client.sh
        ```

        修改/etc/consul.d/client.hcl
        ```bash
        node_name = "dsc-1"
        bind_addr = "10.1.2.1"
        retry_join = ["10.1.1.1", "10.1.1.2", "10.1.1.3"]
        ```

    - DCS-2

        ```
        ~# cd ~/beehive-deploy
        ~# ./install-client.sh
        ```

        修改/etc/consul.d/client.hcl
        ```bash
        node_name = "dsc-2"
        bind_addr = "10.1.2.2"
        retry_join = ["10.1.1.1", "10.1.1.2", "10.1.1.3"]
        ```

    - DCS-3

        ```
        ~# cd ~/beehive-deploy
        ~# ./install-client.sh
        ```

        修改/etc/consul.d/client.hcl
        ```bash
        node_name = "dsc-3"
        bind_addr = "10.1.2.3"
        retry_join = ["10.1.1.1", "10.1.1.2", "10.1.1.3"]
        ```

    - MSA-1

        ```
        ~# cd ~/beehive-deploy
        ~# ./install-client.sh
        ```

        修改/etc/consul.d/client.hcl
        ```bash
        node_name = "msa-1"
        bind_addr = "10.1.100.1"
        retry_join = ["10.1.1.1", "10.1.1.2", "10.1.1.3"]
        ```

    - MSA-2

        ```
        ~# cd ~/beehive-deploy
        ~# ./install-client.sh
        ```

        修改/etc/consul.d/client.hcl
        ```bash
        node_name = "msa-2"
        bind_addr = "10.1.100.2"
        retry_join = ["10.1.1.1", "10.1.1.2", "10.1.1.3"]
        ```

    - MSA-3

        ```
        ~# cd ~/beehive-deploy
        ~# ./install-client.sh
        ```

        修改/etc/consul.d/client.hcl
        ```bash
        node_name = "msa-3"
        bind_addr = "10.1.100.3"
        retry_join = ["10.1.1.1", "10.1.1.2", "10.1.1.3"]
        ```

    - BLA-1

        ```
        ~# cd ~/beehive-deploy
        ~# ./install-client.sh
        ```

        修改/etc/consul.d/client.hcl
        ```bash
        node_name = "bla-1"
        bind_addr = "10.1.200.1"
        retry_join = ["10.1.1.1", "10.1.1.2", "10.1.1.3"]
        ```

    - BLA-2

        ```
        ~# cd ~/beehive-deploy
        ~# ./install-client.sh
        ```

        修改/etc/consul.d/client.hcl
        ```bash
        node_name = "bla-2"
        bind_addr = "10.1.200.2"
        retry_join = ["10.1.1.1", "10.1.1.2", "10.1.1.3"]
        ```

    - MSA-3

        ```
        ~# cd ~/beehive-deploy
        ~# ./install-client.sh
        ```

        修改/etc/consul.d/client.hcl
        ```bash
        node_name = "bla-3"
        bind_addr = "10.1.200.3"
        retry_join = ["10.1.1.1", "10.1.1.2", "10.1.1.3"]
        ```



- 重启

    在每个节点上执行以下命令，重启系统。
    ```
    ~# reboot
    ```

如果内存有限，可以参照以下配置调整虚拟机的资源。

|虚拟机|cpu|启动内存|启用动态内存|最小内存|最大内存|
|:--|:--|:--|:--|:--|:--|
|SRC|2|256M|否|||
|DSC|2|768M|是|512M|1024M|
|MSA|2|768M|是|512M|1024M|

- 浏览

    使用浏览器打开以下任何一个SRC的地址，都可打开UI
    ```
    10.1.1.1:8500
    10.1.1.2:8500
    10.1.1.3:8500
    ```

## 测试

在 http://10.1.1.1:8500/ui/dc1/kv 中新建一个名为omo/msa/config/default.yaml的key，对应值的类型为YAML，内容为
```yaml
logger:
  level: 3
```

在宿主机上使用Windows Terminal打开Alpine Shell,编译[omo-msa-startkit](https://github.com//xtech-cloud/omo-msa-startkit)，编译完成后得到omo-msa-startkit,将omo-msa-startkit拷贝到每个MSA中。
```bash
~# scp ~/omo-msa-startkit/omo-msa-startkit root@10.1.100.1:/root/
~# scp ~/omo-msa-startkit/omo-msa-startkit root@10.1.100.2:/root/
~# scp ~/omo-msa-startkit/omo-msa-startkit root@10.1.100.3:/root/
```

使用Hyper-V的虚拟连接或者ssh在每个MSA上运行omo-msa-startkit

首先创建一个退出就删除的容器用于测试。
```bash
~# docker run -it --rm --net=host -v /root:/root alpine:3.11 /bin/sh
```

进入容器后,设置相关环境变量。
```bash
/# export MSA_REGISTRY_PLUGIN=consul
/# export MSA_REGISTRY_ADDRESS=127.0.0.1:8500
/# export MSA_CONFIG_DEFINE='{"source":"consul", "prefix":"/omo/msa/config", "key":"default.yaml", "address":["127.0.0.1:8500"]}'
/# ./omo-msa-startkit &
```

浏览 http://10.1.1.2:8500/ui/dc1/services/omo.msa.startkit ，不出意外的话，应该能看到以下内容

|ID|Node|
|:--|:--|
|omo.msa.startkit-...|msa-1|
|omo.msa.startkit-...|msa-2|
|omo.msa.startkit-...|msa-3|

服务已经通过所在节点的Consul Client已经分别注册到了SRC上。

现在在BLA中模拟客户端调用服务,需要使用编译omo-msa-startkit过程中,,使用`make tcall`得到的bin文件夹中的client。

在宿主机的Alpine Shell中拷贝client到BLA上。

```bash
scp ~/omo-msa-startkit/bin/client root@10.1.200.1:/root/
```

在BLA-1的SShell中运行一个容器进行测试
```bash
~# docker run -it --rm --net=host -v /root:/root alpine:3.11 /bin/sh
```

在容器中运行client

```bash
/# export MSA_CONFIG_DEFINE='{"source":"consul", "prefix":"/omo/msa/config", "key":"default.yaml", "address":["127.0.0.1:8500"]}'
/# /root/client
```

服务正常的话，会得到以下内容
```json
2020...... | MSA-StartKit
```

留意3个MSA的控制台输出，被访问的服务会显示以下内容
```
 [Received StartKit.Call request]
```

随着Client的不断调用，可以看到3个服务会被随机访问。

### 模拟服务异常

使用以下命令退出MSA-1上运行的mo-msas-startkit。输入内容时会有被调用的日志输出，不必理会，输完命令回车。
```bash
~# pkill omo-msa-startkit
```

输入回车后会看到以下显示，表示进程已经结束。
```
[1]+  Done                       ./omo-msa-startkit
```

Consul UI中omo.msa.start服务的数量发生变化。BLA没有失败的显示，这是因为正常退出时，服务会向SRC发送消息注销自己。可以在MSA-1的控制台输出看到这行显示。
```
Broker [eats] Disconnected from 127.0.0.1:-1
```

现在模拟服务异常故障的情况，在MSA-2上使用以下命令直接杀死进程。
```bash
~# pkill -9 omo-msa-startkit
```

连续按下回车，直到看到以下显示
```
[1]+  Killed                     ./omo-msa-startkit
```

进程被杀掉后Consul UI上没有变化，但BLA-1上的控制台输出，有时会返回错误。这是因为SRC还在等待服务重新注册，约60秒后,Consul UI上异常服务的ServiceCheck亮红，BLA-1的控制台输出已没有错误信息,再经过60秒后，异常的服务被注销，从Consul UI上消失。

重新运行MSA-2和MSA-3退出的omo-msa-startkit，使用pill -9的方式结束MSA-2和MSA-3上的omo-msa-startkit，可以看到client在连接失败后会重试，如果3次重试都访问到异常的服务，那么当前这次调用失败。重试策略默认是随机算法。


### 模拟SRC节点异常

`强制关机`任何一台SRC（需保证至少两台SRC在运行），MSA运行的omo-msa-startkit有可能会显示错误信息，BLA的调用也可能会出现失败，不过很快就恢复正常。


### 模拟MSA节点异常

`强制关机`MSA-1，BLA的调用正常。
`强制关机`MSA-2，BLA的调用正常。

强制关闭MSA时，Consul Server会很快检测到MSA上的Consul Clinet失联，当BLA中运行的client(omo-msa-startkit中的)访问服务时，会先访问本地的Consul Client，而Consul Clinet通过向Consul Server进行查询，获取到所有节点的状态，最终client(omo-msa-starkit)调用服务时跳过异常的节点。

# Product
