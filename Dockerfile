# syntax=docker/dockerfile:1

## Build
FROM golang:1.25-bookworm AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./

RUN go build -o /taintmanager

## Deploy
FROM gcr.io/distroless/base-debian12

WORKDIR /

COPY --from=build /taintmanager /taintmanager

USER nonroot:nonroot

CMD ["/taintmanager"]
