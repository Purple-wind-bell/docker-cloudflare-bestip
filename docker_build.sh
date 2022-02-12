# 登录dockerhub
# echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
git pull
docker build -t zfl666/cloudflare-bestip:latest .
docker push zfl666/cloudflare-bestip:latest
