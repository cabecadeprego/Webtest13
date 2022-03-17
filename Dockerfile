FROM golang:alpine AS build

RUN apk add --no-cache curl git alpine-sdk

ARG SWAGGER_UI_VERSION=3.20.9

RUN dir=$(mktemp -d) \
    && git clone https://github.com/go-swagger/go-swagger "$dir" \
    && cd "$dir" \
    && go mod init v1
    && go env -w GO111MODULE=auto \
    && go install ./cmd/swagger \
    && curl -sfL https://github.com/swagger-api/swagger-ui/archive/v$SWAGGER_UI_VERSION.tar.gz | tar xz -C /tmp/ \
    && mv /tmp/swagger-ui-$SWAGGER_UI_VERSION /tmp/swagger \
    && sed -i 's#"https://petstore\.swagger\.io/v2/swagger\.json"#"./swagger.json"#g' /tmp/swagger/dist/index.html

WORKDIR $GOPATH/src/github.com/marcosranes/Webtest13

COPY go.mod go.sum $GOPATH/src/github.com/marcosranes/Webtest13/

COPY . .

RUN go build -o /Webtest13
RUN swagger generate spec -o /swagger.json

FROM alpine:latest

WORKDIR /Webtest13

COPY assets ./assets
COPY conf.toml ./conf.toml

COPY --from=build /tmp/swagger/dist ./assets/swagger
COPY --from=build /swagger.json ./assets/swagger/swagger.json
COPY --from=build /Webtest13 Webtest13

ENTRYPOINT [ "./Webtest13" ,"serve"]
