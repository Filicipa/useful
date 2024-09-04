# My NGIXN notice and config examples

Для конфигурации NGINX рекомендуется пользоваться [ресурсом](https://https://www.digitalocean.com/community/tools/nginx?global.app.lang=en) для генерирования конфигурации.

Так же рекомендуется использовать модульную структуру конфигурирования. 
 
## Примеры настройки обратного прокси
	Модуль location для простого конфигурирования backend, который, к примеру, запущен в docker на порту 3000. А так же для второго контейнера приложения, запущенного на порту 8080 и настроенного на работу /test, так же приложение настроено на работу по /test.
```
    # reverse proxy
    location / {
        proxy_pass            http://127.0.0.1:3000;
        proxy_set_header Host $host;
        include               nginxconfig.io/proxy.conf;
    }

    # reverse proxy to subfolder
    location /test {
        proxy_pass            http://127.0.0.1:8080;
        proxy_set_header Host $host;
        include               nginxconfig.io/proxy.conf;
    }
```
## Примеры настройки CORS правил для адреса.
Для всех адресов (НЕ рекомендуется к применению)
```
	add_header 'Access-Control-Allow-Origin' '*';
```
Для example.com
```
	add_header 'Access-Control-Allow-Origin' 'https://example.com';

        if ($http_origin = "https://example.com") {
            add_header Access-Control-Allow-Origin $http_origin;
        }
```

Для разрешения CORS с нескольких адресов c дополнительными заголовками. 
	Для этого необходимо создать массив map (разрешается только в модуле http), в данной конфигурации вынесен в отдельный файл. 

```
#nginx.conf
    #Load CORS map
    include /etc/nginx/cors/*.conf;

#./cors.conf
map $http_origin $allow_origin {
    ~^https:\/\/(?:www.)?example.com$ $http_origin;
    http://localhost:3000 $http_origin;
    default "";

#./sites-available/*.conf
    location / {
        proxy_pass            http://127.0.0.1:3001;
        proxy_set_header Host $host;
        include               nginxconfig.io/proxy.conf;

        add_header 'Access-Control-Allow-Origin' $allow_origin;

        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PATCH, DELETE';
        add_header 'Access-Control-Allow-Headers' 'Origin, X-Requested-With, Content-Type, Accept';
    }
```

Примечание:
`location /` - ловит любые запросы, если нет более точных совпадений

`location /test` - ловит запросы /test /test/ /test/1 /test1 etc.

`location /test/` - ловит запросы /test/ /test/1, но не ловит запрос /test1

- если менять uri не нужно, то прописывается только host[+port]
- если менять uri нужно, то прописывается на что менять

Ссылки к ознакомлению  
http://nginx.org/en/docs/http/request_processing.html  
http://nginx.org/en/docs/http/ngx_http_core_module.html#location