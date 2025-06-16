# ================================
# Multi-stage build para optimización
# ================================

# Stage 1: Build Stage
FROM node:18-alpine AS builder

# Metadata
LABEL maintainer="rodolfokenlly@gmail.com"
LABEL description="Task Manager API - Build Stage"

# Instalar dependencias de sistema necesarias para build
RUN apk add --no-cache python3 make g++

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias primero (para cache de Docker layers)
COPY package*.json ./
COPY tsconfig*.json ./

# Instalar TODAS las dependencias (incluyendo devDependencies para el build)
RUN npm ci --silent && \
    npm cache clean --force

# Copiar código fuente
COPY src ./src

# Build de la aplicación
RUN npm run build

# ================================
# Stage 2: Production Stage
# ================================
FROM node:18-alpine AS production

# Metadata
LABEL maintainer="rodolfokenlly@gmail.com"
LABEL description="Task Manager API - Production"
LABEL version="1.0.0"

# Instalar curl para health checks
RUN apk add --no-cache curl

# Crear grupo y usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001 -G nodejs

# Crear directorio de trabajo
WORKDIR /app

# Copiar package.json para instalar solo dependencias de producción
COPY package*.json ./

# Instalar solo dependencias de producción
RUN npm ci --only=production --silent && \
    npm cache clean --force

# Copiar archivos construidos del stage anterior
COPY --from=builder /app/dist ./dist

# Cambiar ownership de los archivos al usuario no-root
RUN chown -R nestjs:nodejs /app

# Cambiar a usuario no-root
USER nestjs

# Exponer puerto
EXPOSE 3000

# Health check (K8s lo puede usar)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Variables de entorno por defecto
ENV NODE_ENV=production
ENV PORT=3000

# Comando para ejecutar la aplicación
CMD ["node", "dist/main.js"]