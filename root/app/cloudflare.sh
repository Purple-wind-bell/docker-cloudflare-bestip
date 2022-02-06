#!/usr/bin/with-contenv sh

cloudflare() {
  if [ -f "$API_KEY_FILE" ]; then
    API_KEY=$(cat $API_KEY_FILE)
  fi

  if [ -z "$EMAIL" ]; then
    curl -sSL \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    "$@"
  else
    curl -sSL \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Auth-Email: $EMAIL" \
    -H "X-Auth-Key: $API_KEY" \
    "$@"
  fi
}

# 运行CloudflareST脚本，输出优选ip到/result/result_hosts.txt
CloudflareST() {
  echo '------开始测速------'
  echo '-------------------------------------------------'
  if [ "$SpeedTest" == "true" ]; then
    cd /workdir
    echo '-------------------------------------------------'
    echo '进入工作目录'
    if [ "$RRTYPE" == "A" ]; then
      ./CloudflareST -f ip.txt -url $SpeedTestUrl -o /result/result_ipv4.txt
      echo '-------------------------------------------------'
      echo '完成ipv4测速'
    elif [ "$RRTYPE" == "AAAA" ]; then
      ./CloudflareST -f ipv6.txt -url $SpeedTestUrl -ipv6 -o /result/result_ipv6.txt
      echo '-------------------------------------------------'
      echo '完成ipv6测速'
    fi
  else
    echo '-------------------------------------------------'
    echo '根据设置跳过测速'
  fi

}

# 从/result/result_hosts.txt中获取优选ip,默认第一个最快的ip,通过IP_NUM参数设置选择第几个ip
getBestIpAddress() {
  ResultRow=1
  if (("$IP_NUM" <= 10)); then
    ResultRow=$IP_NUM
  fi
  if [ "$RRTYPE" == "A" ]; then
    IP_ADDRESS=$(sed -n "$(($IP_NUM + 1)),1p" /result/result_ipv4.txt | awk -F, '{print $1}')
    echo $IP_ADDRESS
  elif [ "$RRTYPE" == "AAAA" ]; then
    IP_ADDRESS=$(sed -n "$(($IP_NUM + 1)),1p" /result/result_ipv6.txt | awk -F, '{print $1}')
    echo $IP_ADDRESS
  fi
}

# 默认子域名为 cfip
getDnsRecordName() {
  if [ ! -z "$SUBDOMAIN" ]; then
    echo $SUBDOMAIN.$ZONE
  else
    echo cfip.$ZONE
  fi
}

verifyToken() {
  if [ -z "$EMAIL" ]; then
    cloudflare -o /dev/null -w "%{http_code}" "$CF_API"/user/tokens/verify
  else
    cloudflare -o /dev/null -w "%{http_code}" "$CF_API"/user
  fi
}

getZoneId() {
  cloudflare "$CF_API/zones?name=$ZONE" | jq -r '.result[0].id'
}

getDnsRecordId() {
  cloudflare "$CF_API/zones/$1/dns_records?type=$RRTYPE&name=$2" | jq -r '.result[0].id'
}

createDnsRecord() {
  if [[ "$PROXIED" != "true" && "$PROXIED" != "false" ]]; then
    PROXIED="false"
  fi
  cloudflare -X POST -d "{\"type\": \"$RRTYPE\",\"name\":\"$2\",\"content\":\"$3\",\"proxied\":$PROXIED,\"ttl\":1 }" "$CF_API/zones/$1/dns_records" | jq -r '.result.id'
}

updateDnsRecord() {
  if [[ "$PROXIED" != "true" && "$PROXIED" != "false" ]]; then
    PROXIED="false"
  fi
  cloudflare -X PATCH -d "{\"type\": \"$RRTYPE\",\"name\":\"$3\",\"content\":\"$4\",\"proxied\":$PROXIED }" "$CF_API/zones/$1/dns_records/$2" | jq -r '.result.id'
}

deleteDnsRecord() {
  cloudflare -X DELETE "$CF_API/zones/$1/dns_records/$2" | jq -r '.result.id'
}

getDnsRecordIp() {
  cloudflare "$CF_API/zones/$1/dns_records/$2" | jq -r '.result.content'
}
