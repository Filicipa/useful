# Создание сертификатов
```bash
mkdir -p ~/services/certs
cd ~/services/certs
```
## Собственный CA
```bash
openssl req -x509 -new -sha256 \
  -key ca.key \
  -days 3650 \
  -out ca.crt \
  -subj "/CN=Internal Docker CA" \
  -addext "basicConstraints=critical,CA:TRUE" \
  -addext "keyUsage=critical,keyCertSign,cRLSign"
```

## Сертификат PostgreSQL
```bash
openssl genrsa -out postgres.key 2048

openssl req -new \
  -key postgres.key \
  -out postgres.csr \
  -subj "/CN=postgres"

printf 'subjectAltName=DNS:postgres\nextendedKeyUsage=serverAuth\n' > postgres.ext

openssl x509 -req \
  -in postgres.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out postgres.crt \
  -days 365 -sha256 \
  -extfile postgres.ext
```
## Сертификат Redis
```bash
openssl genrsa -out redis.key 2048

openssl req -new \
  -key redis.key \
  -out redis.csr \
  -subj "/CN=redis"

printf 'subjectAltName=DNS:redis\nextendedKeyUsage=serverAuth\n' > redis.ext

openssl x509 -req \
  -in redis.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out redis.crt \
  -days 365 -sha256 \
  -extfile redis.ext
```
## Сертификат Valkey
```bash
openssl genrsa -out valkey.key 2048

openssl req -new \
  -key valkey.key \
  -out valkey.csr \
  -subj "/CN=valkey"

printf 'subjectAltName=DNS:valkey\nextendedKeyUsage=serverAuth\n' > valkey.ext

openssl x509 -req \
  -in valkey.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out valkey.crt \
  -days 365 -sha256 \
  -extfile valkey.ext
```

### Проверка сертификатов
### Проверить цепочку доверия
```bash
openssl verify -CAfile ca.crt postgres.crt
openssl verify -CAfile ca.crt redis.crt
openssl verify -CAfile ca.crt valkey.crt
```
### Проверить SAN и назначение сертификатов
```bash
openssl x509 -in postgres.crt -noout -text
openssl x509 -in redis.crt -noout -text
openssl x509 -in valkey.crt -noout -text
```
### Проверка соответствия сертификатов DNS-именам
```bash
openssl x509 -in postgres.crt -noout -checkhost postgres
openssl x509 -in redis.crt -noout -checkhost redis
openssl x509 -in valkey.crt -noout -checkhost valkey
```
### Узнать UID/GID пользователей в образах
```bash
docker run --rm postgres:18.2 id postgres
docker run --rm redis:alpine id redis
docker run --rm valkey/valkey:9.1.0 id valkey
```
### Назначить владельца приватным ключам
UID/GID определяются для конкретного Docker-образа и его версии. Проверять необходимо не только наличие пользователя, но и пользователя, от которого работает основной процесс сервиса. Приватный ключ должен быть доступен этому пользователю на чтение.
```bash
sudo chown <UID>:<GID> postgres.key
sudo chown <UID>:<GID> redis.key
sudo chown <UID>:<GID> valkey.key

sudo chmod 600 postgres.key redis.key valkey.key ca.key
sudo chmod 644 ca.crt postgres.crt redis.crt valkey.crt
```
*Важно: `ca.key` не монтировать в контейнеры. Лучше хранить его отдельно от рабочего сервера, в защищённом месте. Приложениям нужен только `ca.crt`.
```yaml
postgres:
  image: postgres:18.2
  container_name: postgres
  restart: unless-stopped
  volumes:
    - ./postgres_data:/var/lib/postgresql
    - ./certs:/certs:ro
  command:
    - postgres
    - -c
    - ssl=on
    - -c
    - ssl_cert_file=/certs/postgres.crt
    - -c
    - ssl_key_file=/certs/postgres.key
  networks:
    - backend
```
#### pg_hba.conf
```conf
# Local connections via Unix socket (no TCP/TLS)
# Used for local administrative access
local   all             all                                     trust

# Local TCP connections (loopback interface)
# TLS is not required for localhost
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust

# Local replication connections
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            trust
host    replication     all             ::1/128                 trust

# Docker network / remote TCP connections
# TLS is mandatory; password authentication via SCRAM-SHA-256
hostssl all             all             all                     scram-sha-256
```
#### redis.conf
```conf
bind 0.0.0.0
protected-mode yes

port 0
tls-port 6380

tls-cert-file /certs/redis.crt
tls-key-file /certs/redis.key
tls-ca-cert-file /certs/ca.crt

tls-auth-clients no
```
#### valkey.conf
```conf
bind 0.0.0.0
protected-mode yes

port 0
tls-port 6380

tls-cert-file /certs/valkey.crt
tls-key-file /certs/valkey.key
tls-ca-cert-file /certs/ca.crt

tls-auth-clients no
```
```yaml
  redis:
    image: redis:alpine
    container_name: redis
    restart: unless-stopped
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis.conf:/usr/local/etc/redis/redis.conf:ro
      - ./certs:/certs:ro
    networks:
      - backend
```
```yaml
  valkey:
    image: valkey/valkey:9.1.0
    container_name: valkey
    restart: unless-stopped
    command: ["valkey-server", "/usr/local/etc/valkey/valkey.conf"]
    volumes:
      - ./valkey.conf:/usr/local/etc/valkey/valkey.conf:ro
      - ./certs:/certs:ro
    networks:
      - backend
```

### Конфигурация приложения
```
# PostgreSQL
PGHOST=postgres
PGPORT=5432
DB_SSL=true
DB_SSL_CA_FILE=/certs/ca.crt

# Redis или Valkey — в зависимости от используемого сервиса
REDIS_HOST=redis
# REDIS_HOST=valkey
REDIS_PORT=6380
REDIS_TLS=true
REDIS_TLS_CA_FILE=/certs/ca.crt
```
### Монтируем сертификаты в приложение
```
volumes:
  - ./certs/ca.crt:/certs/ca.crt:ro
```
## Проверка
#### PostgreSQL — все подключения должны использовать TLS:
```bash
docker exec postgres psql -U postgres \
  -d compound_integration_api \
  -c "
SELECT a.client_addr, s.ssl, s.version
FROM pg_stat_activity a
JOIN pg_stat_ssl s ON a.pid = s.pid
WHERE a.client_addr IS NOT NULL;
"
```
Ожидаем `ssl = t, TLSv1.3.`
#### PostgreSQL — проверить запрет plaintext:
```bash
docker run --rm --network backend postgres:18.2 \
  psql "host=postgres port=5432 user=postgres dbname=compound_integration_api sslmode=disable connect_timeout=5" \
  -c "SELECT 1;"
```
```bash
docker exec redis redis-cli --tls \
  --cacert /certs/ca.crt \
  -h redis -p 6380 PING
```
#### Redis — plaintext должен быть отключён:
```bash
docker exec redis redis-cli --tls \
  --cacert /certs/ca.crt \
  -h redis -p 6380 CONFIG GET port tls-port
```
Ожидаем
```
port
0
tls-port
6380
```
```bash
docker exec redis redis-cli -h redis -p 6379 PING
```
Ожидаем отказ соединения.

#### Valkey 
```bash
docker exec valkey valkey-cli --tls \
  --cacert /certs/ca.crt \
  -h valkey -p 6380 PING
```

```bash
docker exec valkey valkey-cli --tls \
  --cacert /certs/ca.crt \
  -h valkey -p 6380 CONFIG GET port tls-port
  ```
  ```bash
  docker exec valkey valkey-cli -h valkey -p 6379 PING
  ```
  Ожидаем отказ соединения.
