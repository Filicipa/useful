# ПОЛНЫЙ ГАЙД ПО НАСТРОЙКЕ VAULT APPROLE ДЛЯ MYAPP
## --- 1. ПОДГОТОВКА СРЕДЫ ---
Все команды выполняются в Vault. Если Vault запущен в контейнере, то необходимо зайти в контейнер:
```bash
docker exec -it vault-server sh
```
выполнить:
```bash
export VAULT_ADDR=http://127.0.0.1:8200
vault login
```
Ввести свой `Initial Root Token`

## --- 2. ВКЛЮЧЕНИЕ МЕТОДОВ И ДВИЖКОВ ---
```bash
vault auth enable approle
```
Убедитесь, что KV движок включен под именем 'kv'
```bash
vault secrets enable -path=kv kv-v2
```

## --- 3. СОЗДАНИЕ ПОЛИТИКИ (myapp-policy.hcl) ---
### Выполнить в терминале:
```bash
cat <<EOF > myapp-policy.hcl
path "kv/data/myapp/*" {
  capabilities = ["read", "list"]
}
path "kv/metadata/myapp/*" {
  capabilities = ["read", "list"]
}
EOF
||
cat <<EOF > market-maker-evm-policy.hcl
path "kv/data/market-maker-evm" {
  capabilities = ["read", "list"]
}
EOF
```
## Запись политики в Vault:
```bash
vault policy write myapp-policy myapp-policy.hcl
```
## --- 4. НАСТРОЙКА APPROLE ---
```bash
vault write auth/approle/role/myapp-role \\
    token_policies="myapp-policy" \\
    token_ttl=1h \\
    token_max_ttl=4h
||
vault write auth/approle/role/market-maker-role token_policies="market-maker-policy" token_ttl=10m token_max_ttl=15m
```
## --- 5. ПОЛУЧЕНИЕ ДОСТУПОВ ДЛЯ ПРИЛОЖЕНИЯ ---
### RoleID (статический):
```bash
vault read auth/approle/role/myapp-role/role-id
```

### SecretID (динамический, сохранить его):
```bash
vault write -f auth/approle/role/myapp-role/secret-id
```

## --- 6. ПРИМЕР КОДА НА NODEJS ---
```js
const vault = require('node-vault')({
  apiVersion: 'v1',
  endpoint: 'http://127.0.0.1:8200'
});

const roleId = '<ROLE_ID>';
const secretId = '<SECRET_ID>';

async function getVaultSecrets() {
  try {
    // Авторизация через AppRole
    const result = await vault.approleLogin({
      role_id: roleId,
      secret_id: secretId
    });

    // Установка токена доступа
    vault.token = result.auth.client_token;
    console.log('Авторизация успешна!');

    // Чтение секретов (путь соответствует политике)
    const secret = await vault.read('kv/data/myapp/config');
    console.log('Секреты получены:', secret.data.data);
    
    return secret.data.data;
  } catch (err) {
    console.error('Ошибка Vault:', err.response ? err.response.body : err.message);
  }
}

getVaultSecrets();
```

## Для Vault UI

### 2. Разрешаем UI "видеть" папку myapp в списке (без этого будет ошибка в UI)
```
path "kv/metadata/myapp/*" {
  capabilities = ["list", "read"]
}
```
### 3. Разрешаем UI видеть сам движок 'kv' на верхнем уровне
```
path "kv/metadata/" {
  capabilities = ["list"]
}
```