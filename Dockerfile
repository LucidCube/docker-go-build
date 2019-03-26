FROM golang:1.12.1-alpine

WORKDIR /

RUN apk --no-cache add git curl gcc musl-dev
RUN mkdir -p /go/src
RUN curl https://glide.sh/get | sh
RUN go get -u github.com/golang/dep/cmd/dep

COPY build.sh /build.sh

CMD [ "/build.sh" ]
