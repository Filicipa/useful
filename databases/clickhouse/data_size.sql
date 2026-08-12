SELECT
    formatReadableSize(sum(data_compressed_bytes))   AS compressed,
    formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed,
    round(sum(data_uncompressed_bytes) / sum(data_compressed_bytes), 2) AS compression_ratio
FROM system.parts
WHERE active;

SELECT
    database,
    formatReadableSize(sum(data_compressed_bytes)) AS compressed,
    formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed,
    sum(rows) AS rows
FROM system.parts
WHERE active
GROUP BY database
ORDER BY sum(data_compressed_bytes) DESC;


SELECT
    `table`,
    formatReadableSize(sum(data_compressed_bytes)) AS compressed,
    formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed,
    sum(rows) AS rows
FROM system.parts
WHERE active AND (database = 'system')
GROUP BY `table`
ORDER BY sum(data_compressed_bytes) DESC
LIMIT 20;

SELECT
    name,
    value,
    changed
FROM system.server_settings
WHERE name LIKE 'logger.%'
ORDER BY name;

# Logging size
SELECT
    `table`,
    formatReadableSize(sum(bytes_on_disk)) AS size,
    sum(rows) AS rows
FROM system.parts
WHERE database = 'system'
  AND `table` IN (
      'processors_profile_log',
      'query_log',
      'trace_log',
      'text_log',
      'part_log',
      'metric_log',
      'asynchronous_metric_log'
  )
  AND active
GROUP BY `table`
ORDER BY sum(bytes_on_disk) DESC;

# Logging size
SELECT
    `table`,
    formatReadableSize(sum(bytes_on_disk)) AS size,
    sum(rows) AS rows
FROM system.parts
WHERE (database = 'system') AND active
GROUP BY `table`
HAVING sum(bytes_on_disk) > 0
ORDER BY sum(bytes_on_disk) DESC;
