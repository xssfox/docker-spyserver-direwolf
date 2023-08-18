```
cp .env.example .env
vi .env
docker run --rm --name igate --env-file=.env ghcr.io/xssfox/docker-spyserver-direwolf:latest
```