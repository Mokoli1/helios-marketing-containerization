# Multi-stage build for production optimization
ARG NODE_VERSION=18
ARG NGINX_VERSION=1.25-alpine

# Build stage
FROM node:${NODE_VERSION}-alpine AS builder

WORKDIR /app

# Copy package files for dependency installation
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Production stage
FROM nginx:${NGINX_VERSION} AS production

# Set build arguments for metadata
ARG BUILD_DATE
ARG VCS_REF

# Add metadata labels following OCI standards
LABEL org.opencontainers.image.title="Helios Marketing Site - DevOps Portfolio" \
      org.opencontainers.image.description="Enterprise-grade containerized marketing site demonstrating advanced DevOps practices" \
      org.opencontainers.image.created="${BUILD_DATE:-unknown}" \
      org.opencontainers.image.revision="${VCS_REF:-unknown}" \
      org.opencontainers.image.vendor="Mokoli1" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://github.com/Mokoli1/helios-marketing-containerization" \
      org.opencontainers.image.source="https://github.com/Mokoli1/helios-marketing-containerization" \
      org.opencontainers.image.documentation="https://github.com/Mokoli1/helios-marketing-containerization/blob/main/README.md"

# Install security updates and required packages
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        dumb-init \
        curl \
        tzdata && \
    rm -rf /var/cache/apk/*

# The nginx:alpine image already has nginx user/group configured
# Set proper permissions for nginx directories
RUN chown -R nginx:nginx /var/cache/nginx /var/log/nginx /etc/nginx/conf.d

# Copy custom nginx configuration
COPY --from=builder --chown=nginx:nginx /app/docker/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder --chown=nginx:nginx /app/docker/default.conf /etc/nginx/conf.d/default.conf

# Copy built application from builder stage
COPY --from=builder --chown=nginx:nginx /app/ /usr/share/nginx/html/

# Remove development files from production image
RUN rm -f /usr/share/nginx/html/Dockerfile \
          /usr/share/nginx/html/docker-compose.yml \
          /usr/share/nginx/html/package*.json \
          /usr/share/nginx/html/.git* \
          /usr/share/nginx/html/README.md && \
    rm -rf /usr/share/nginx/html/docker/ && \
    chown -R nginx:nginx /usr/share/nginx/html

# Create required nginx directories with proper permissions
RUN mkdir -p /var/run/nginx \
             /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp && \
    chown -R nginx:nginx /var/run/nginx /var/cache/nginx

# Copy and set up health check script
COPY docker/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh && \
    chown nginx:nginx /usr/local/bin/healthcheck.sh

# Expose port 8080 (matching our nginx configuration)
EXPOSE 8080

# Add comprehensive health check using our custom script
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Switch to non-root user for security
USER nginx

# Use dumb-init to handle signals properly and start nginx
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["nginx", "-g", "daemon off;"] 