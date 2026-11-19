# SSH-деплой через GitHub Actions: known_hosts и fingerprint

Краткая инструкция для деплоя Docker-образов на сервер. Здесь два варианта SSH-подключения: обычный `ssh` (например, передача Docker TAR через stdin) и `appleboy/ssh-action` (выполнение разрешённой команды деплоя).

## 1. SSH-ключ для деплоя

Создать отдельную пару ключей (на доверенной машине):

```bash
ssh-keygen -t ed25519 -f ./github_deploy_key -C github-deploy
```

- **Приватный** `github_deploy_key` записать в **GitHub Secrets** → `SSH_KEY`. 
- **Публичный** `github_deploy_key.pub` добавить на сервер в `/home/ubuntu/.ssh/authorized_keys`. Для ограниченного деплоя:

```text
restrict,command="/usr/local/bin/deploy.sh" ssh-ed25519 AAAA... github-deploy
```

`deploy.sh` должен быть исполняемым и разрешать только необходимые значения `SSH_ORIGINAL_COMMAND` через `case`. Команды из GitHub выполняются под пользователем `ubuntu`; не давать этому ключу обычную shell-сессию.

## 2. `SSH_KNOWN_HOSTS` — для OpenSSH

**Получать публичный host key:**

```bash
sudo cat /etc/ssh/ssh_host_ed25519_key.pub
```

Результат вида `ssh-ed25519 AAAAC3... server-comment`. Для GitHub Variable `SSH_KNOWN_HOSTS` записать **одной строкой**:

```text
SERVER_IP ssh-ed25519 AAAAC3...
```

`SERVER_IP` — адрес, по которому GitHub подключается к серверу. Если SSH использует нестандартный порт `2222`, формат первого поля: `[SERVER_IP]:2222`.

Альтернативно с доверенной машины:

```bash
ssh-keyscan -t ed25519 SERVER_IP
```

**Важно:** `ssh-keyscan` сам по себе не подтверждает подлинность сервера. Сверить полученный ключ с `/etc/ssh/ssh_host_ed25519_key.pub` по доверенному каналу (или сверить SHA256-отпечатки). Не принимать результат сканирования без проверки.

Добавить значение в **GitHub Variables** `SSH_KNOWN_HOSTS`. Публичный host key не является секретом.

Пример использования в workflow (передача файла в SSH stdin):

```yaml
- name: Upload Docker image
  env:
    SSH_KEY: ${{ secrets.STAGE_SSH_KEY }}
    KNOWN_HOSTS: ${{ vars.STAGE_SSH_KNOWN_HOSTS }}
    HOST: ${{ vars.STAGE_NAME }}@${{ vars.STAGE_IP }}
  run: |
    set -euo pipefail
    eval "$(ssh-agent -s)"
    trap 'ssh-agent -k >/dev/null 2>&1 || true' EXIT
    ssh-add - <<< "$SSH_KEY"
    unset SSH_KEY
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    printf '%s\n' "$KNOWN_HOSTS" > ~/.ssh/known_hosts
    chmod 600 ~/.ssh/known_hosts
    ssh -o BatchMode=yes -o StrictHostKeyChecking=yes "$HOST" upload-api < "${IMAGE_NAME}.tar"
```

Пример предполагает, что `IMAGE_NAME` уже определён, а TAR-файл создан в этом job. Команда `upload-api` должна быть разрешена в серверном `deploy.sh`.

## 3. `SSH_FINGERPRINT` — для appleboy/ssh-action

На **самом сервере** узнать SHA256-отпечаток host key:

```bash
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub -E sha256
```

Результат вида:

```text
256 SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx root@server (ED25519)
```

В GitHub Variable `SSH_FINGERPRINT` записать **только** `SHA256:xxxxxxxx...` (без размера, комментария и типа ключа).

**Важный нюанс:** SSH-сервер может предлагать ED25519, ECDSA и RSA host keys. `appleboy` проверяет отпечаток **того host key, который фактически выбран при SSH-handshake**. Если выбран ECDSA, а задан отпечаток ED25519, появится `ssh: host key fingerprint mismatch`.

Узнать отпечатки всех доступных host keys на сервере:

```bash
for type in ed25519 ecdsa rsa; do
  sudo ssh-keygen -lf "/etc/ssh/ssh_host_${type}_key.pub" -E sha256
done
```

Выбрать отпечаток ключа, используемого соединением `appleboy` (в нашем случае на одном из серверов выбирался ECDSA). При несовпадении **не отключать проверку**, а определить согласованный алгоритм и корректный отпечаток.

Пример workflow:

```yaml
- name: Deploy API
  uses: appleboy/ssh-action@0ff4204d59e8e51228ff73bce53f80d53301dee2
  with:
    host: ${{ vars.STAGE_IP }}
    username: ${{ vars.STAGE_NAME }}
    key: ${{ secrets.STAGE_SSH_KEY }}
    fingerprint: ${{ vars.STAGE_SSH_FINGERPRINT }}
    command_timeout: 20m
    script: deploy-api
```

`deploy-api` — разрешённая команда в `case "${SSH_ORIGINAL_COMMAND:-}"` на сервере.

## 4. Как устроен `/usr/local/bin/deploy.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

upload-api() {
    cat > "${IMAGE}.tmp"
    mv -f "${IMAGE}.tmp" "${IMAGE}.tar"
    docker load -i "${IMAGE}.tar"
}

deploy_api() {
    docker compose -f "$COMPOSE" up -d --no-deps api
}

case "${SSH_ORIGINAL_COMMAND:-}" in
  upload-api) upload_api ;;
  deploy-api) deploy_api ;;
  *) echo "Permission denied" >&2; exit 1 ;;
esac
```

Проверка на сервере без GitHub (под тем же пользователем, что используется для SSH):

```bash
SSH_ORIGINAL_COMMAND=deploy-api /usr/local/bin/deploy.sh
```

**Осторожно:** эта команда реально выполнит деплой. Для безопасной проверки блокировки неизвестных команд:

```bash
SSH_ORIGINAL_COMMAND=unknown-command /usr/local/bin/deploy.sh
# Ожидается: Permission denied
```

Простой вызов `/usr/local/bin/deploy.sh deploy-api` **не работает**: скрипт читает `SSH_ORIGINAL_COMMAND`, а не `$1`.

## 5. Быстрая памятка

| GitHub variable/secret                 | Что хранит                  | Откуда брать                                                | Где используется                                   |
| -------------------------------------- | --------------------------- | ----------------------------------------------------------- | -------------------------------------------------- |
| `STAGE_SSH_KEY` (**Secret**)           | Приватный deploy-ключ       | Созданная пара SSH-ключей                                   | `ssh-agent`, `appleboy key`                        |
| `STAGE_SSH_KNOWN_HOSTS` (**Variable**) | `IP ssh-ed25519 AAAA...`    | Публичный host key сервера, проверенный доверенным способом | `~/.ssh/known_hosts` + `StrictHostKeyChecking=yes` |
| `STAGE_SSH_FINGERPRINT` (**Variable**) | `SHA256:...`                | `ssh-keygen -lf /etc/ssh/ssh_host_*_key.pub -E sha256`      | `appleboy fingerprint`                             |
| `STAGE_IP` (**Variable**)              | IP/имя сервера              | Инфраструктура                                              | SSH host                                           |
| `STAGE_NAME` (**Variable**)            | SSH-пользователь (`ubuntu`) | Сервер                                                      | SSH username                                       |

Для DEV заменить префикс `STAGE_` на `DEV_`. **Не путать:** deploy key (`authorized_keys`) аутентифицирует GitHub перед сервером; host key (`known_hosts`/`fingerprint`) аутентифицирует сервер перед GitHub.
