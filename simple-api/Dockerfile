FROM golang:1.15.0-alpine3.12 as builder

ADD . /go/src/kublr.io/demo/devops-demo/simple-api

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go install  -a -installsuffix cgo -ldflags="-w -s" kublr.io/demo/devops-demo/simple-api
ADD ./content /go/bin/content/

FROM scratch

COPY --from=builder /go/bin/simple-api /go/bin/simple-api
COPY --from=builder /go/bin/content/ /go/bin/content/

WORKDIR /go/bin/
EXPOSE 8000
ENTRYPOINT ["/go/bin/simple-api"]
