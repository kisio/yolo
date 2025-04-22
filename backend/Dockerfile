# Build stage
FROM node:13.12.0 as builder
WORKDIR /app
COPY package*.json ./
RUN npm config set registry https://registry.npmjs.org/ && \
    npm config set fetch-retries 5 && \
    npm config set fetch-retry-factor 2 && \
    npm config set fetch-retry-mintimeout 10000 && \
    npm config set fetch-retry-maxtimeout 60000 && \
    npm install

# Production stage
FROM node:13.12.0-slim
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .

# Maintainer label
LABEL maintainer="kisio <derrickkisio@gmail.com>"

# Health check for backend service
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:5000/ || exit 1

# Create non-root user for security
RUN groupadd -r appgroup && useradd -r -g appgroup appuser && \
    chown -R appuser:appgroup /app
USER appuser

EXPOSE 5000
CMD ["npm", "start"]