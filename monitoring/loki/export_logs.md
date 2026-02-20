```bash
logcli query '{instance="prod-backend", container_name="bot"}' \
  --since=336h \
  --limit=0 \
  --output=raw \
  > bot-logs-14d.log
```
