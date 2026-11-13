FROM golang:1.13 as builder

WORKDIR /src

COPY . .

RUN go build

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:0e48b9bcd868bce9fa872cee10b52961d9e32677823da4bf68eefb44f38e7b9d
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>

COPY --from=builder /src/fakesha /usr/local/bin/
COPY --from=builder /src/stories.txt.gz /

EXPOSE 8080
ENTRYPOINT ["fakesha"]
