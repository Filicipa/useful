FROM python:3.12 AS builder
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV POETRY_HOME=/etc/poetry
RUN curl -sSL https://install.python-poetry.org | python3 - --version 1.5.1
ENV PATH=$POETRY_HOME/bin:$PATH
COPY pyproject.toml poetry.lock ./
ENV POETRY_VIRTUALENVS_CREATE=false
RUN poetry install --no-root --without dev

FROM python:3.12-slim AS runner
RUN apt-get update -y && \
    apt-get install python3-psycopg2 -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/lib/python3.12/site-packages/ /usr/local/lib/python3.12/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/
WORKDIR /app
COPY . .
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh", "start_service"]
