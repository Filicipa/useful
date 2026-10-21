# Создание сертификатов
```bash
mkdir -p ~/services/certs
cd ~/services/certs
```
## Собственный CA
```bash
openssl genrsa -out ca.key 4096

openssl req -x509 -new -sha256 \
  -key ca.key \
  -days 3650 \
  -out ca.crt \
  -subj "/CN=Internal Docker CA"
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
### Указать пользователя внутри контейнера базы данных
```bash
sudo chown <user>:<user> postgres.key
sudo chown <user>:<user> redis.key

sudo chmod 600 postgres.key redis.key ca.key
sudo chmod 644 ca.crt postgres.crt redis.crt
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
# Unix socket
local   all             all                                     trust

# Local TCP
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust

# Replication
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            trust
host    replication     all             ::1/128                 trust

# Docker / remote TCP — TLS only
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
### Конфигурация приложения
```
# PostgreSQL
PGHOST=postgres
PGPORT=5432
DB_SSL=true
DB_SSL_CA_FILE=/certs/ca.crt

# Redis
REDIS_HOST=redis
REDIS_PORT=6380
REDIS_TLS=true
REDIS_TLS_CA_FILE=/certs/ca.crt
```
### Монтируем сертификаты
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
