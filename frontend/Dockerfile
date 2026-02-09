# ========================================
# Build Dependencies Stage
# ========================================
ARG NODE_VERSION=20-alpine
FROM node:${NODE_VERSION} AS deps

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm ci --omit=dev && \
    npm cache clean --force

# ========================================
# Build Stage
# ========================================
FROM node:${NODE_VERSION} AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm ci && \
    npm cache clean --force

# Copy source code
COPY . .

# Build Next.js application
RUN npm run build

# ========================================
# Production Stage
# ========================================
FROM node:${NODE_VERSION} AS production

WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs && \
    chown -R nodejs:nodejs /app

# Set production environment variables
ENV NODE_ENV=production \
    NODE_OPTIONS="--max-old-space-size=512 --no-warnings" \
    NPM_CONFIG_LOGLEVEL=silent

# Copy production dependencies from deps stage
COPY --from=deps --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=deps --chown=nodejs:nodejs /app/package*.json ./

# Copy built application from builder stage
COPY --from=builder --chown=nodejs:nodejs /app/.next ./.next
COPY --from=builder --chown=nodejs:nodejs /app/public ./public

# Accept NEXT_PUBLIC_ variables at build time (optional - for dynamic values)
ARG NEXT_PUBLIC_API_BASE_URL
ARG NEXT_PUBLIC_CHATKIT_ENABLED
ARG NEXT_PUBLIC_APP_ENV
ENV NEXT_PUBLIC_API_BASE_URL=${NEXT_PUBLIC_API_BASE_URL} \
    NEXT_PUBLIC_CHATKIT_ENABLED=${NEXT_PUBLIC_CHATKIT_ENABLED} \
    NEXT_PUBLIC_APP_ENV=${NEXT_PUBLIC_APP_ENV}

# Switch to non-root user
USER nodejs

# Expose port 3000
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Start Next.js server
CMD ["node_modules/.bin/next", "start"]
