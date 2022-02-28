#!/bin/bash

if [ $# -eq 0 ]; then
	echo "No mount folder supplied"
	exit 1
fi

image="manylinux2014_i686"
rust=false
toolchain="stable"

for i in "$@"; do
	if [ "$i" = "$1" ]; then
		continue
	fi
	if [ "$i" = "--x86-64" ]; then
		image="manylinux2014_x86_64"
	fi
	if [ "$i" = "--rust" ]; then
		rust=true
	fi
	if [ "$i" = "--nightly" ]; then
		toolchain="nightly"
	fi
done

echo Stopping and removing existing image
docker stop $image
docker rm $image

echo Starting...
if [ "$rust" = true ]; then
	docker run -it --name $image --mount type=bind,source="$1",target=/hostmnt -p 80:80 quay.io/pypa/$image /bin/bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain $toolchain --profile minimal -y && source \$HOME/.cargo/env && /bin/bash"
else
	docker run -it --name $image --mount type=bind,source="$1",target=/hostmnt -p 80:80 quay.io/pypa/$image /bin/bash
fi
