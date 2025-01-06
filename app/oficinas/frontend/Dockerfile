# ----------------------------------
# Stage 1: Build Stage
# ----------------------------------
FROM node:23-alpine3.20 AS builder

# Set environment variables
ENV NODE_ENV=production
ENV YARN_VERSION=1.22.22

# Set working directory
WORKDIR /app

# Install system dependencies required for building Yarn and Node.js
RUN apk add --no-cache bash build-base curl gnupg libstdc++ \
    && apk add --no-cache --virtual .build-deps \
        curl \
        gnupg \
        tar

# Instalar Yarn via npm somente se não estiver instalado
RUN if ! command -v yarn >/dev/null 2>&1; then \
        npm install -g yarn@1.22.22 && \
        yarn --version; \
    else \
        echo "Yarn já está instalado."; \
    fi

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy package.json and yarn.lock to leverage Docker caching
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# Build the Next.js application
RUN yarn build

# ----------------------------------
# Stage 2: Production Stage
# ----------------------------------
FROM node:23-alpine3.20 AS runtime

# Set environment variables
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache libstdc++

# Copy built assets from the builder stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/yarn.lock ./yarn.lock

# Install only production dependencies
RUN yarn install --production --frozen-lockfile

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the port Next.js runs on
EXPOSE 3000

# Define the command to run the app
CMD ["yarn", "start"]

# ----------------------------------
# Optional: Healthcheck
# ----------------------------------
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1

