- ### Create pg_stat_statements Extension for Each Database

```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```
- ### Check pg_stat_statements
```sql
SELECT count(*) FROM pg_stat_statements;
```