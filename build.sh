#!/bin/sh

if [ "$BUILD_UID" != "" -a $(whoami) = "root" ]
then
	if [ "$BUILD_GID" != "" ]
	then
		groupadd --gid $BUILD_GID buildgroup
		adduser --disabled-password --gecos '' --gid $BUILD_GID --uid $BUILD_UID builduser
		chown -R builduser.buildgroup /go
	else
		adduser --disabled-password --gecos '' --uid $BUILD_UID builduser
		chown -R builduser /go
	fi

	export HOME=/home/builduser
	if [ -f /root/.netrc ]
	then
		cp /root/.netrc $HOME/.netrc
		chown builduser $HOME/.netrc
		chmod 0600 $HOME/.netrc
	fi

	exec su -m builduser -c $0 $@
fi

export GOPATH=/go
export PATH=/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

cd /go/src/$PACKAGE

# Run dep or glide if necessary (dep takes precedence)
if [ -f Gopkg.toml ]
then
	echo "Running dep ensure..."
	dep ensure
	RET=$?
	if [ $RET -ne 0 ]
	then
		echo "dep ensure failed with return code $RET"
	fi
elif [ -f glide.yaml ]
then
	echo "Running glide install..."
	glide install
	RET=$?
	if [ $RET -ne 0 ]
	then
		echo "glide install failed with return code $RET"
	fi
elif [ -f go.mod ]
then
	# No Gopkg.toml or glide.yaml so enable Go 1.11 modules
	export GO111MODULE=on
fi

echo "Building go project in $(pwd)..."
/usr/local/go/bin/go build -ldflags "-linkmode external -extldflags -static"
