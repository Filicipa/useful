`crontab -e`
```
0 3 * * * sudo /bin/bash /home/ubuntu/mongo_backup/backup_script.sh >/dev/null 2>&1
```
```bash
mongodump --authenticationDatabase=admin --username="omomo" --password=6J!ErK --db=test --out ~/back --gzip
```
кавычек нет в пароле

```
mongorestore --db=test /home/ubuntu/back/test/ --gzip
```
```
mongorestore --authenticationDatabase=admin --username="omomo" --password="password" --db=test --gzip ~/back/test/
```