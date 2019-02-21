FROM golang:1.11-alpine3.8

WORKDIR /

RUN apk --no-cache add git curl gcc musl-dev
RUN mkdir -p /go/src
RUN curl https://glide.sh/get | sh
RUN go get -u github.com/golang/dep/cmd/dep

COPY build.sh /build.sh

CMD [ "/build.sh" ]
