ARG S6_ARCH
FROM oznu/s6-alpine:3.12-${S6_ARCH:-amd64}

RUN apk add --no-cache jq curl bind-tools

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
CF_API=https://api.cloudflare.com/client/v4 \
RRTYPE=A \
CRON="0 */3 * * *" \
CloudflareSpeedTest_URL=https://download.fastgit.org/XIU2/CloudflareSpeedTest/releases/latest/download/CloudflareST_linux_amd64.tar.gz \
IP_NUM=1 \
SpeedTest=true \
SpeedTestUrl=https://speed.acfun-win.workers.dev/100mb.test

COPY root /
