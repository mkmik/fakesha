FROM golang:1.13 as builder

WORKDIR /src

COPY . .

RUN go build

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:9ef50bca108839d5986e4d84b7f7b2d79024c9293b7c35b162c6c55485bd5868
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>

COPY --from=builder /src/fakesha /usr/local/bin/
COPY --from=builder /src/stories.txt.gz /

EXPOSE 8080
ENTRYPOINT ["fakesha"]
