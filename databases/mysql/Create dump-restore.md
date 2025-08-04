## Dump MySQL
`mysqldump -h <db_host> -u <db_user> -p <db_name> > <dump_name>.sql`

## Dump MySQL RDS
`mysqldump --single-transaction --set-gtid-purged=OFF -h <db_host> -u <db_user> -p <db_name> > <dump_name>.sql`


## Solution 1 to avoid AWS RDS errors
Comment out or remove these lines
```
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 1;
SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';
```

## Solution 2
You can also ignore the errors by using the `-f` option to load the rest of the dump file.

## Restore
`mysql <REPLACE_DB_NAME> -u <REPLACE_DB_USER> -h <DB_HOST_HERE> -p < dumpfile.sql`