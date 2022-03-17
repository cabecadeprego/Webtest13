FROM golang:alpine AS build

RUN apk add --no-cache curl git alpine-sdk

ARG SWAGGER_UI_VERSION=3.20.9

RUN dir=$(mktemp -d) \
    && git clone https://github.com/go-swagger/go-swagger "$dir" \
    && cd "$dir" \
    && go install ./cmd/swagger \
    && curl -sfL https://github.com/swagger-api/swagger-ui/archive/v$SWAGGER_UI_VERSION.tar.gz | tar xz -C /tmp/ \
    && mv /tmp/swagger-ui-$SWAGGER_UI_VERSION /tmp/swagger \
    && sed -i 's#"https://petstore\.swagger\.io/v2/swagger\.json"#"./swagger.json"#g' /tmp/swagger/dist/index.html

RUN go get github.com/GeertJohan/go.rice/rice

WORKDIR $GOPATH/src/github.com/marcosranes/Webtest13

COPY go.mod go.sum $GOPATH/src/github.com/marcosranes/Webtest13/

RUN go get ./...
RUN go mod tidy

COPY . .

RUN CGO_ENABLED="0" go build -ldflags="-s -w" -a -o /Webtest13
RUN swagger generate spec -o /swagger.json \
 && cp /swagger.json ui/assets/swagger/ \
 && cp -R /tmp/swagger/dist ui/assets/swagger

RUN cd ui && rice append --exec /Webtest13

FROM alpine:latest

WORKDIR /Webtest13

COPY conf.toml ./conf.toml
COPY --from=build /Webtest13 Webtest13

ENTRYPOINT [ "./Webtest13" ]
