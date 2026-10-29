FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --upgrade --no-cache-dir pip==26.2.2 && \
    pip install --no-cache-dir -r requirements.txt
COPY ./ ./
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

EXPOSE 8080

CMD ["python", "app.py"]