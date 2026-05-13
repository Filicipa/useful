SELECT query, queryid, max_exec_time
FROM pg_stat_statements
ORDER BY max_exec_time DESC
LIMIT 10;