```bash
sudo certbot certonly --standalone -d your_domain
```

## Certbot in compose
! nginx will running and listen port 80 

```nginx
server {
    listen 80;
    server_name ${DOMAIN};

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://${DOMAIN}/$request_uri;
    }
}
```

```yml
services:
  nginx:
    container_name: ms_nginx
    image: nginx
    ports:
      - 80:80
      - 443:443
    restart: always
    networks:
      - nginx

  certbot:
    image: certbot/certbot:latest
    container_name: certbot
    volumes:
      - ./certbot/www/:/var/www/certbot/:rw
      - ./certbot/conf/:/etc/letsencrypt/:rw
    networks:
      - nginx
```
Run command 
```bash
docker compose run --rm certbot certonly --webroot --webroot-path=/var/www/certbot -d mealshift.co.uk -d www.mealshift.co.uk -d dashboard.mealshift.co.uk --email you@gmail.com --agree-tos --no-eff-email --non-interactive
```