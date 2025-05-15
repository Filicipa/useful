## Full dump
```
pg_dump -h <hostname> -p 5432 -U <username> -Fc -b -v -f <dumpfilelocation.sql> -d  <database_name>
```
- -h is the name of source server where you would like to migrate your database.
- -U is the name of the user present on the source server
- -Fc: Sets the output as a custom-format archive suitable for input into `pg_restore`. !!!binary 
- -b: Include large objects in the dump.
- -v: Specifies verbose mode
- -f: Dump file path

## Restore NEED CHECK
```
pg_restore -v -h <hostname> -U <username> -d <database_name> -j 2 <dumpfilelocation.sql>
```

## DUMP example RDS
```
pg_dump -h prod-postgres.j0.eu-central-1.rds.amazonaws.com -p 5432 -U postgres -b -v -f file-backup.sql -d postgres
```

## RESTORE
```
psql -h host -p 5432 -U user -d db-name -f file-backup.sql
```
# DOCKER
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