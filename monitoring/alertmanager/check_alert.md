```bash
curl -s http://localhost:9093/api/v2/alerts   | jq '.[] | select(.labels env == "stage") | {
    status: .status.state,
    alertname: .labels.alertname,
    instance: .labels.instance,
    job: .labels.job,
    service: .labels.service,
    severity: .labels.severity
}'
```