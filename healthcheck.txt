# Health check

### Health Check Endpoint Specifications:

1. **URL Path:**
    - The health check endpoint has a specific URL path named `/api/health`.
    e.g. [https://example.com/api/health](https://example.com/health).
    
    Reference: https://microservices.io/patterns/observability/health-check-api.html
    
2. **HTTP Method:**
    - The health check endpoint is accessed using a lightweight HTTP method `GET`. The endpoint should not modify any state or data.
3. **Response Format:**
    - The health check response should be in a JSON format. It should include information about the health status of the application and its dependencies.
4. **HTTP Status Codes:**
    - The health check response should use appropriate HTTP status codes to indicate the health status:
        - `200 OK`: Indicates a healthy state.
        - `503 Service Unavailable`: Indicates an unhealthy state.
5. **Response Body (for JSON):**

```json
{
  "status": "ok",
  "details": {
    "application": "healthy",
    "database": "connected",
    "redis": "connected"
  }
}
```

1. **Response Time:**
    - The health check endpoint should respond quickly (<10ms), ideally within a few milliseconds, to avoid affecting the monitoring system's performance.