# FROM nginx:1.23.1-alpine
# COPY web/build /usr/share/nginx/html/
# EXPOSE 80

FROM --platform=$BUILDPLATFORM golang:1.18-alpine AS builder

WORKDIR /code

ENV GOPATH /go
ENV GOOS js
ENV GOARCH wasm
ENV CGO_ENABLED 0
ENV GOCACHE /go-build


COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod/cache \
    go mod download

COPY . .

RUN --mount=type=cache,target=/go/pkg/mod/cache \
    --mount=type=cache,target=/go-build \
    go build -o web/generator.wasm src/web/main.go

FROM node:14.17.3-alpine3.14 as backend

WORKDIR /usr/src/app
RUN ls -lrth
COPY --from=builder /code/web .

RUN npm install
RUN npm run build --if-present

FROM nginx:1.23.1-alpine as web
COPY --from=backend /usr/src/app/build /usr/share/nginx/html/
EXPOSE 80



