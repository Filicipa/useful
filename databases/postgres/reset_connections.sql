SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state = 'idle'
  AND datname = 'your_database_name'
  AND pid <> pg_backend_pid();