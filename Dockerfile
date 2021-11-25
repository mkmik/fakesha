FROM golang:1.13 as builder

WORKDIR /src

COPY . .

RUN go build

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:4f25af540d54d0f43cd6bc1114b7709f35338ae97d29db2f9a06012e3e82aba8
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>

COPY --from=builder /src/fakesha /usr/local/bin/
COPY --from=builder /src/stories.txt.gz /

EXPOSE 8080
ENTRYPOINT ["fakesha"]
