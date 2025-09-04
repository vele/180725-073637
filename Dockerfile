FROM golang:1.21 AS builder

WORKDIR /app

COPY src/go.mod ./
COPY src/main.go ./

RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -o internal-service main.go

FROM gcr.io/distroless/base-debian12

WORKDIR /app
COPY --from=builder /app/internal-service .

USER 65532:65532

EXPOSE 8080

ENTRYPOINT ["/app/internal-service"]

