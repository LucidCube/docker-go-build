FROM golang:1.11

WORKDIR /

RUN curl https://glide.sh/get | sh
RUN mkdir -p /go/src

# zlib1g-dev gettext libcurl4-openssl-dev are needed to compile git below
RUN apt-get -y update && \
	apt-get install -y --no-install-recommends ca-certificates zlib1g-dev gettext libcurl4-openssl-dev && \
	apt-get clean

# Install git 2.19 from source to work around the bug (see https://github.com/golang/go/issues/26894)
COPY git-2.19.1.tar.gz /usr/src
RUN cd /usr/src && \
	tar zxf git-2.19.1.tar.gz && \
	cd /usr/src/git-2.19.1 && \
	./configure --without-tcltk && \
	make && \
	make install && \
	rm -rf /usr/src/git-2.19.1.tar.gz /usr/src/git-2.19.1

RUN go get -u github.com/golang/dep/cmd/dep

COPY build.sh /build.sh

CMD [ "/build.sh" ]
