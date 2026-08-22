# =========================
# Build stage
# =========================
FROM python:3.12-alpine AS builder

WORKDIR /build

COPY app/requirements.txt .

RUN pip install --no-cache-dir \
    --prefix=/install \
    -r requirements.txt


# =========================
# Runtime stage
# =========================
FROM python:3.12-alpine

WORKDIR /app

COPY --from=builder /install /usr/local

COPY app/ .

# Remove pip from the runtime image
RUN rm -rf \
    /usr/local/lib/python3.12/site-packages/pip \
    /usr/local/lib/python3.12/site-packages/pip-*.dist-info \
    /usr/local/bin/pip \
    /usr/local/bin/pip3

EXPOSE 5001

CMD ["python", "app.py"]
