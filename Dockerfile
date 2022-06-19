FROM golang:1.13 as builder

WORKDIR /src

COPY . .

RUN go build

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:cd46126707e268844faec3aca618761c6728170e08ccf1f174dbc7ed7ca1b36a
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>

COPY --from=builder /src/fakesha /usr/local/bin/
COPY --from=builder /src/stories.txt.gz /

EXPOSE 8080
ENTRYPOINT ["fakesha"]
