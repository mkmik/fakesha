FROM golang:1.13 as builder

WORKDIR /src

COPY . .

RUN go build

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:a08c76433d484340bd97013b5d868edfba797fbf83dc82174ebd0768d12f491d
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>

COPY --from=builder /src/fakesha /usr/local/bin/
COPY --from=builder /src/stories.txt.gz /

EXPOSE 8080
ENTRYPOINT ["fakesha"]
