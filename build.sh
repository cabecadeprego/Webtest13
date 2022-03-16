#!/bin/sh

if [ -d "dist" ]; then
    rm -rf dist
fi

mkdir -p dist

go mod tidy

CGO_ENABLED="0" go build -ldflags="-s -w" -a -v -o Webtest13 .

pushd ui
rice append --exec ../Webtest13
popd

cp Webtest13 dist/
cp conf.toml dist/

rm Webtest13
