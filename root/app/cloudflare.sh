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

# 运行CloudflareST脚本，输出优选ip到result_hosts.txt
CloudflareST() {
  if [ "$RRTYPE" == "A" ]; then
      ./CloudflareST_linux_amd64/CloudflareST -f ip.txt -o result_hosts.txt
  elif [ "$RRTYPE" == "AAAA" ]; then
      ./CloudflareST_linux_amd64/CloudflareST ipv6.txt -ipv6 -o result_hosts.txt
  fi
}


# 从result_hosts.txt中获取优选ip,传参优选ip序号
# 例如，查询第三个优选ip，调用 getBestIpAddress 3
getBestIpAddress() {
    IP_ADDRESS=$(sed -n "${$1 + 1},1p" /CloudflareST_linux_amd64/result_hosts.txt | awk -F, '{print $1}')
  echo $IP_ADDRESS
}

# 从result_hosts.txt中获取优选ip数组，传参IP_NUM
getBestIpAddressList() {
    IP_ADDRESS_LIST=$(sed -n "2,$1p" /CloudflareST_linux_amd64/result_hosts.txt)
  echo $IP_ADDRESS_LIST
}

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
