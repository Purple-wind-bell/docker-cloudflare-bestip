# Docker CloudFlare DDNS

此docker镜像基于 oznu/docker-cloudflare-ddns 和 XIU2/CloudflareSpeedTest 改写，以优选cloudflare IP，并将其写入指定域名的dns记录，从而实现快速获取优选ip的目的。

理论上linux都能自行构建docker镜像。

## 用法

快速:

```shell
docker run \
  -e API_KEY=xxxxxxx \
  -e ZONE=example.com \
  -e SUBDOMAIN=subdomain \
  -e IP_NUM=1 \
  oznu/cloudflare-ddns
```

## 参数

* `--restart=always` - 容器始终自动重启
* `-e API_KEY` - `CloudFlare` 的 `API token`。 详见 [Creating a Cloudflare API token](#creating-a-cloudflare-api-token)。 **必须**
  * `API_KEY_FILE` - 加载 CloudFlare API token 的路径 (e.g. a Docker secret). *If both `API_KEY_FILE` and `API_KEY` are specified, `API_KEY_FILE` takes precedence.*
* `-e ZONE` - The DNS zone that DDNS updates should be applied to. **Required**
  * `ZONE_FILE` - Path to load your CloudFlare DNS Zone from (e.g. a Docker secret). *If both `ZONE_FILE` and `ZONE` are specified, `ZONE_FILE` takes precedence.*
* `-e SUBDOMAIN` - A subdomain of the `ZONE` to write DNS changes to. If this is not supplied the root zone will be used.
  * `SUBDOMAIN_FILE` - Path to load your CloudFlare DNS Subdomain from (e.g. a Docker secret). *If both `SUBDOMAIN_FILE` and `SUBDOMAIN` are specified, `SUBDOMAIN_FILE` takes precedence.*
* `-e IP_NUM=1` - 优选IP数量，只支持最大10个，默认1个，将以 `ip-1.mysubdomain.com, ip-2.mysubdomain.com` 的形式实现。

## Optional Parameters

* `-e PROXIED` - Set to `true` to make traffic go through the CloudFlare CDN. Defaults to `false`.
* `-e RRTYPE=A` - Set to `AAAA` to use set IPv6 records instead of IPv4 records. Defaults to `A` for IPv4 records.
* `-e DELETE_ON_STOP` - Set to `true` to have the dns record deleted when the container is stopped. Defaults to `false`.
* `-e INTERFACE=tun0` - Set to `tun0` to have the IP pulled from a network interface named `tun0`. If this is not supplied the public IP will be used instead. Requires `--network host` run argument.
* `-e CUSTOM_LOOKUP_CMD="echo '1.1.1.1'"` - Set to any shell command to run them and have the IP pulled from the standard output. Leave unset to use default IP address detection methods.
* `-e DNS_SERVER=10.0.0.2` - Set to the IP address of the DNS server you would like to use. Defaults to 1.1.1.1 otherwise. 
* `-e CRON="@daily"` - Set your own custom CRON value before the exec portion. Defaults to every 5 minutes - `*/5 * * * *`.

## Depreciated Parameters

* `-e EMAIL` - Your CloudFlare email address when using an Account-level token. This variable MUST NOT be set when using a scoped API token.

## Creating a Cloudflare API token

To create a CloudFlare API token for your DNS zone go to https://dash.cloudflare.com/profile/api-tokens and follow these steps:

1. Click Create Token
2. Provide the token a name, for example, `cloudflare-ddns`
3. Grant the token the following permissions:
    * Zone - Zone Settings - Read
    * Zone - Zone - Read
    * Zone - DNS - Edit
4. Set the zone resources to:
    * Include - All zones
5. Complete the wizard and copy the generated token into the `API_KEY` variable for the container

## 多个优选ip

如果需要多个优选ip，可以使用 `IP_NUM` 参数。

## IPv6

If you're wanting to set IPv6 records set the envrionment variable `RRTYPE=AAAA`. You will also need to run docker with IPv6 support, or run the container with host networking enabled.

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
      - IP_NUM=1
```

## License

Copyright (C) 2017-2020 oznu

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the [GNU General Public License](./LICENSE) for more details.
