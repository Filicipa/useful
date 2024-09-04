#!/bin/bash
URL="https://example.com/api/health"

check_response_code() {
  curl -s -o /dev/null -w "%{http_code}" $URL
}

attempts=3
interval=20
success=false

for ((i=1; i<=attempts; i++)); do
  RESPONSE_CODE=$(check_response_code)
  if [ "$RESPONSE_CODE" -eq 200 ]; then
    success=true
    break
  fi

  if [ $i -lt $attempts ]; then
    sleep $interval
  fi
done

if $success; then
  echo "Responce code 200. All right."
else
  echo "Responce code $RESPONSE_CODE. Webhook."
  curl -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"Bash script test <@userid>\"}" \
  https://discord.com/api/webhooks/
fi
