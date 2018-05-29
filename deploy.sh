cd $GOPATH/src/github.com/micro/micro && \
git checkout feature/auth && \
GOOS=linux GOARCH=amd64 go build && \
docker build -t sipsynergy/micro-web-auth:test . && \
docker save -o ./micro-web-auth sipsynergy/micro-web-auth:test && \
scp ./micro-web-auth dev:/tmp && \
ssh -t -t dev << \eof1
(docker rm -f micro-web-auth; true) && \
docker load -i /tmp/micro-web-auth && \
docker run -d \
    -p 8083:8083 \
    -e CONSUL_HTTP_HOST="172.30.120.210:8500" \
    -e MICRO_REGISTRY_ADDRESS="172.30.120.210:8500" \
    -e MICRO_CLIENT_REQUEST_TIMEOUT="30s" \
    --name=micro-web-auth \
    sipsynergy/micro-web-auth:test web \
        --address=0.0.0.0:8083 \
        --cors=*
eof1