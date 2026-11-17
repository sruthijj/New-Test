# ─────────────────────────────────────────
# Production Stage: High Performance Nginx
# ─────────────────────────────────────────
FROM nginx:stable-alpine AS base

# Metadata
LABEL maintainer="sruthij1221@gmail.com"
LABEL description="AWS Cloud Topology Dashboard static website served via Nginx"

# Remove default Nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy website static assets into web root
COPY . /usr/share/nginx/html/

# Expose HTTP port 80
EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
