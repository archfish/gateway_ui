# API网关图形配置工具

[网关项目](https://github.com/fagongzi/gateway)

基于ruby on rails进行开发，通过restful进行配置管理。

## 安装

```shell
# Docker required
git clone https://github.com/ArchFish/gateway_ui.git
cd gateway_ui
make
```

## 启动

```shell
docker run -d --restart always -p 6000:6000 \
        --name gateway_ui \
        -u 1001:1001 \
        -h gateway.ui.production \
        -l SERVICE_80_NAME=gatewayui \
        -e RAILS_ENV=production \
        -e GATEWAY_BACKEND=gateway_container_service:port \
        gateway_ui:[your tag]
```

`SERVICE_80_NAME`用于consul服务发现的服务名，可忽略；
`RAILS_ENV`配置rails运行的环境，必须为production；
`GATEWAY_BACKEND`网关restful API的服务地址+端口号；
打包出来的images的tag自动以`%Y%m%d%H%M`格式保存；


## 注意

项目没有做权限管理，同时也不打算做这个功能，安全性上只能通过网络限制实现，请不要将服务运行在开放的外网环境中。
