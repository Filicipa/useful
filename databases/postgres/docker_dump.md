### Backup your databases
```bash
docker exec -t <your-db-container> pg_dumpall -c -U <postgres> > dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql
```
Creates filename like `dump_2023-12-25_09_15_26.sql`

If you want a smaller file size, use gzip:
```bash
docker exec -t <your-db-container> pg_dumpall -c -U <postgres> | gzip > dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql.gz
```
### Restore your databases
```bash
cat <your_dump.sql> | docker exec -i <your-db-container> psql -U <postgres> <database>
```
or
```bash
cat <your_dump.sql> | docker exec -i <your-db-container> pg_restore -U <USER> -d <database>