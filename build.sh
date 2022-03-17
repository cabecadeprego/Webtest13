#!/bin/sh

if [ -d "dist" ]; then
    rm -rf dist
fi

mkdir -p dist

go mod tidy

CGO_ENABLED="0" go build -ldflags="-s -w" -a -v -o Webtest13 .

pushd ui+-


rm Webtest13
