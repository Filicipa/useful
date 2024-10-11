# Project name
### Description
### API

1. GET `https://{host}/api/health`
##### Query
```curl
curl "https://project.example.com/api/health"
```

##### Response
```json5
{
    "status": "String",            // Enum: "ok", "bad"
    "details": {
        "database": {
            "status": "String"     // Enum: "up", "down"
        }
    }
}

200 OK
```
  
3. GET `https://{host}/api/mvrv/z-score?time_start=<unix_timestamp>&time_end=<unix_timestamp>`
##### Query
```curl
curl "https://project.example.com/api/mvrv/z-score?time_start=1715299200&time_end=1715299800"
```

##### Response
```json5
{
    "mvrv_z_score": "String"       // Numeric: https://docs.rs/rust_decimal/latest/rust_decimal/struct.Decimal.html
}

200 OK
400 BAD_REQUEST
500 INTERNAL_SERVER_ERROR
503 SERVICE_UNAVAILABLE
```

---

### Build

```rust
cargo build
```

### Start

```rust
[RUST_LOG=..] cargo run
```

### Test

```rust
cargo test
```

---

### Docker Ruild

```docker
docker build -t <image_name> .
```

### Docker Run

```
docker run -d -p <HOST_PORT>:<CONTAINER_PORT> --env-file .env <image_name>
```

### Docker Stop

```
docker stop <CONTAINER_ID>
```

---

### .env Example

```ini
RUST_LOG=info
HOST=0.0.0.0
PORT=8080
PG_DBNAME=testdb
PG_USER=postgres
PG_PASSWORD=qwerty123
PG_HOST=dbhost
PG_PORT=5432
STREAMINGFAST_JWT=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
COINMARKETCAP_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ZERO_TIME_POINT_TIMESTAMP=1715299200
ZERO_TIME_POINT_MARKET_CAP=68499423025.730446
ZERO_TIME_POINT_PRICE=152.8113138032191
PROCESS_BLOCKS_WORKER_START_BLOCK=264853590
```

### Environment Variables

| Environment Variable                | Type   | Default Value      | Description                                                                         |
| ----------------------------------- | ------ | ------------------ | ----------------------------------------------------------------------------------- |
| `DATABASE_URL`                      | String | -                  | Required                                                                            |
| `HOST`                              | String | "0.0.0.0"          | Optional                                                                            |
| `PORT`                              | u16    | 3000               | Optional                                                                            |
| `NODE_ENV`                          | String | develop/production | Optional                                                                            |
| `PG_DBNAME`                         | String | -                  | Required                                                                            |
| `PG_USER`                           | String | -                  | Required                                                                            |
| `PG_PASSWORD`                       | String | -                  | Required                                                                            |
| `PG_HOST`                           | String | -                  | Required                                                                            |
| `PG_PORT`                           | u16    | -                  | Required                                                                            |
| `STREAMINGFAST_JWT`                 | String | -                  | Required (https://substreams.streamingfast.io/documentation/consume/authentication) |
| `COINMARKETCAP_API_KEY`             | String | -                  | Required (https://coinmarketcap.com/academy/article/what-is-an-api-key)             |
| `ZERO_TIME_POINT_TIMESTAMP`         | i64    | -                  | Required                                                                            |
| `ZERO_TIME_POINT_MARKET_CAP`        | f64    | -                  | Required                                                                            |
| `ZERO_TIME_POINT_PRICE`             | f64    | -                  | Required                                                                            |
| `PROCESS_BLOCKS_WORKER_START_BLOCK` | i64    | -                  | Required                                                                            |

---

#### How to get PROCESS_BLOCKS_WORKER_START_BLOCK tip
Using Bitquery API v1 (https://ide.bitquery.io/) with the query below you can get start block slot

```graphql
query MyQuery {
  solana {
    blocks(date: {since: "2024-04-24"}, options: {limit: 1}) {
      height
    }
  }
}
```
