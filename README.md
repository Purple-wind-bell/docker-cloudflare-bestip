# Docker 优选 CloudFlare ip + DDNS

此 docker 镜像基于 [oznu/docker-cloudflare-ddns](https://github.com/oznu/docker-cloudflare-ddns) 和 [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) 改写，以优选 cloudflare IP，并将其写入指定域名的 dns 记录，从而实现快速获取优选 ip 的目的。

## 用法

## Docker Compose

If you prefer to use [docker-compose.yml](https://docs.docker.com/compose/):

```
version: '3'
services:
  cloudflare-ddns:
    image: oznu/cloudflare-ddns:latest
    restart: always
    environment:
      - API_KEY=xxxxxxx
      - ZONE=example.com
      - SUBDOMAIN=subdomain
      - PROXIED=false
      - RRTYPE=AAAA
      - IP_NUM=1
      - SpeedTest=true
      - CloudflareSpeedTest_URL=https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.0.3/CloudflareST_linux_amd64.tar.gz
      - SpeedTestUrl=https://speed.acfun-win.workers.dev/100mb.test
    volumes:
      - ./data/result:/result
    networks:
      macvlan-net:
        ipv4_address: 192.168.31.30
networks:
  macvlan-net:
    external: true
```

## 参数

- `restart=always` - 容器始终自动重启。
- `API_KEY` - `CloudFlare` 的 `API token`。 详见 [Creating a Cloudflare API token](#creating-a-cloudflare-api-token)。 **必须**
  - `API_KEY_FILE` - 加载 CloudFlare API token 的路径 (e.g. a Docker secret). _If both `API_KEY_FILE` and `API_KEY` are specified, `API_KEY_FILE` takes precedence._
- `ZONE` - The DNS zone that DDNS updates should be applied to. **Required**
  - `ZONE_FILE` - Path to load your CloudFlare DNS Zone from (e.g. a Docker secret). _If both `ZONE_FILE` and `ZONE` are specified, `ZONE_FILE` takes precedence._
- `SUBDOMAIN` - A subdomain of the `ZONE` to write DNS changes to. If this is not supplied the root zone will be used.
  - `SUBDOMAIN_FILE` - Path to load your CloudFlare DNS Subdomain from (e.g. a Docker secret). _If both `SUBDOMAIN_FILE` and `SUBDOMAIN` are specified, `SUBDOMAIN_FILE` takes precedence._
- `IP_NUM=1` - 内置脚本支持优选 10 个 ip，此参数可以设置选择第几个，配合多容器实现更新多个优选 ip。
- `SpeedTest` - 是否启用内置的优选脚本，默认为 true，设置为 false 时用于配合`./data/result:/result`实现多容器共享优选 ip 文件。
- `CloudflareSpeedTest_URL` - cloudflare 优选 ip 的脚本下载链接，默认 x86_64，详见[XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)，不知道怎么设置最新发布地址。。。。。。
- `./data/result:/result` - 映射容器内测速结果，方便多容器共享，配合 `SpeedTest` 参数使用。
- `ipv4_address` - macvlan 模式指定容器 ip。
- `macvlan-net` - macvlan 网络名称，需要另外设置，相关信息搜索`docker macvlan`关键词。
- `SpeedTestUrl` - 测速文件url

## Optional Parameters

- `-e PROXIED` - Set to `true` to make traffic go through the CloudFlare CDN. Defaults to `false`.
- `-e RRTYPE=A` - Set to `AAAA` to use set IPv6 records instead of IPv4 records. Defaults to `A` for IPv4 records.
- `-e DELETE_ON_STOP` - Set to `true` to have the dns record deleted when the container is stopped. Defaults to `false`.
- `-e INTERFACE=tun0` - Set to `tun0` to have the IP pulled from a network interface named `tun0`. If this is not supplied the public IP will be used instead. Requires `--network host` run argument.
- `-e CUSTOM_LOOKUP_CMD="echo '1.1.1.1'"` - Set to any shell command to run them and have the IP pulled from the standard output. Leave unset to use default IP address detection methods.
- `-e DNS_SERVER=10.0.0.2` - Set to the IP address of the DNS server you would like to use. Defaults to 1.1.1.1 otherwise.
- `-e CRON="@daily"` - Set your own custom CRON value before the exec portion. Defaults to every 5 minutes - `*/5 * * * *`.

## Depreciated Parameters

- `-e EMAIL` - Your CloudFlare email address when using an Account-level token. This variable MUST NOT be set when using a scoped API token.

## Creating a Cloudflare API token

To create a CloudFlare API token for your DNS zone go to https://dash.cloudflare.com/profile/api-tokens and follow these steps:

1. Click Create Token
2. Provide the token a name, for example, `cloudflare-ddns`
3. Grant the token the following permissions:
   - Zone - Zone Settings - Read
   - Zone - Zone - Read
   - Zone - DNS - Edit
4. Set the zone resources to:
   - Include - All zones
5. Complete the wizard and copy the generated token into the `API_KEY` variable for the container

## IPv6

If you're wanting to set IPv6 records set the envrionment variable `RRTYPE=AAAA`. You will also need to run docker with IPv6 support, or run the container with host networking enabled.

## License

Copyright (C) 2017-2020 oznu

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the [GNU General Public License](./LICENSE) for more details.
