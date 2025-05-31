# 🚀 Task Manager API

Una aplicación completa de gestión de tareas construida con **NestJS**, containerizada con **Docker** y preparada para **Kubernetes**. Este proyecto sirve como base práctica para aprender containerización y orquestación de aplicaciones.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Arquitectura](#-arquitectura)
- [Tecnologías](#-tecnologías)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Endpoints API](#-endpoints-api)
- [Docker](#-docker)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)
- [Kubernetes](#-kubernetes)
- [Contribución](#-contribución)

## ✨ Características

- 🔐 **Autenticación JWT** completa
- 📝 **CRUD de tareas** con autorización
- 👥 **Gestión de usuarios**
- 🐘 **Base de datos PostgreSQL**
- 🔴 **Cache con Redis**
- 🐳 **Completamente containerizada**
- 🌐 **Reverse proxy con Nginx**
- 💚 **Health checks** para Kubernetes
- 🔧 **Variables de entorno configurables**
- 📊 **Estadísticas de tareas**

## 🏗️ Arquitectura

```
🌐 Internet/Browser (Puerto 80)
    ↓
📊 Nginx Reverse Proxy
    ↓
🚀 NestJS API (Puerto 3000)
    ↓
🐘 PostgreSQL + 🔴 Redis
```

### Componentes

- **API**: NestJS con TypeScript
- **Base de Datos**: PostgreSQL 15
- **Cache**: Redis 7
- **Proxy**: Nginx Alpine
- **Containerización**: Docker + Docker Compose

## 🛠️ Tecnologías

- **Backend**: NestJS, TypeScript, Node.js 18
- **Base de Datos**: PostgreSQL, TypeORM
- **Autenticación**: JWT, Passport, bcryptjs
- **Validación**: class-validator, class-transformer
- **Containerización**: Docker, Docker Compose
- **Proxy**: Nginx
- **Cache**: Redis

## 📥 Instalación

### Prerrequisitos

- Node.js 18+
- Docker & Docker Compose
- Git

### 1. Clonar y Setup

```bash
# Clonar el proyecto
git clone <tu-repo>
cd task-manager-api

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
```

### 2. Variables de Entorno

Edita el archivo `.env`:

```bash
# Database
DB_HOST=localhost
DB_PORT=5433
DB_USERNAME=postgres
DB_PASSWORD=password
DB_NAME=taskmanager

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=24h

# App
NODE_ENV=development
PORT=3000

# Redis
REDIS_HOST=localhost
REDIS_PORT=6380
```

## 🚀 Uso

### Desarrollo Local

```bash
# Levantar servicios externos (PostgreSQL + Redis)
npm run docker:dev

# Iniciar la aplicación en modo desarrollo
npm run start:dev

# La API estará disponible en: http://localhost:3000/api
```

### Stack Completo con Docker

```bash
# Levantar todo el stack (API + DB + Redis + Nginx)
npm run docker:run

# Ver logs
npm run docker:logs

# Parar todo
npm run docker:down
```

### Scripts Disponibles

```bash
# Desarrollo
npm run start:dev          # Modo desarrollo con hot reload
npm run build              # Construir para producción
npm run start:prod         # Ejecutar en modo producción

# Docker
npm run docker:dev         # Solo servicios externos
npm run docker:dev:down    # Parar servicios externos
npm run docker:build       # Construir imagen Docker
npm run docker:run         # Stack completo
npm run docker:down        # Parar stack completo
npm run docker:logs        # Ver logs del stack
npm run docker:clean       # Limpiar completamente

# Testing
npm run test               # Unit tests
npm run test:e2e           # End-to-end tests
npm run test:cov           # Coverage
```

## 📡 Endpoints API

### Autenticación

```bash
# Registrar usuario
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "123456",
  "name": "User Name"
}

# Login
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "123456"
}
```

### Tareas (Requieren autenticación)

```bash
# Listar tareas
GET /api/tasks
Headers: Authorization: Bearer <token>

# Crear tarea
POST /api/tasks
Headers: Authorization: Bearer <token>
{
  "title": "Nueva tarea",
  "description": "Descripción opcional",
  "dueDate": "2025-02-01T10:00:00Z"
}

# Obtener tarea específica
GET /api/tasks/:id
Headers: Authorization: Bearer <token>

# Actualizar tarea
PATCH /api/tasks/:id
Headers: Authorization: Bearer <token>
{
  "status": "completed"
}

# Eliminar tarea
DELETE /api/tasks/:id
Headers: Authorization: Bearer <token>

# Estadísticas
GET /api/tasks/stats
Headers: Authorization: Bearer <token>
```

### Health Check

```bash
# Health check básico
GET /api/health

# Readiness check
GET /api/health/ready

# Liveness check
GET /api/health/live
```

## 🐳 Docker

### Estructura de Archivos

```
task-manager-api/
├── src/                    # Código fuente
├── Dockerfile             # Imagen de la aplicación
├── docker-compose.yml     # Stack completo
├── docker-compose.dev.yml # Solo servicios externos
├── nginx.conf             # Configuración de Nginx
├── .dockerignore          # Archivos a excluir
└── .env                   # Variables de entorno
```

### Dockerfile

- **Multi-stage build** para optimización
- **Usuario no-root** para seguridad
- **Health checks** integrados
- **Imagen Alpine** para menor tamaño

### Servicios Docker

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| nginx    | 80     | Reverse proxy |
| api      | 3000   | Aplicación NestJS |
| postgres | 5432   | Base de datos |
| redis    | 6379   | Cache |

### Acceso a Servicios

- **Vía Nginx (Recomendado)**: `http://localhost/api/*`
- **API Directa (Debug)**: `http://localhost:3000/api/*`

## 🧪 Testing

### Testing Manual

```bash
# Usar el script de testing automatizado
chmod +x test-nginx-stack.sh
./test-nginx-stack.sh
```

### Testing con curl

```bash
# Health check
curl http://localhost/health

# Registrar usuario
curl -X POST http://localhost/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "123456",
    "name": "Test User"
  }'

# Crear tarea (reemplaza TOKEN)
curl -X POST http://localhost/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "title": "Mi primera tarea",
    "description": "Descripción de prueba"
  }'
```

## 🔧 Troubleshooting

### Problemas Comunes

#### 1. Error 500 en registro de usuarios

```bash
# Verificar logs de la API
docker logs taskmanager-api

# Si aparece "relation users does not exist":
# Asegúrate de que NODE_ENV=development en docker-compose.yml
```

#### 2. No se puede conectar a la base de datos

```bash
# Verificar que PostgreSQL esté corriendo
docker ps | grep postgres

# Verificar logs de PostgreSQL
docker logs taskmanager-db
```

#### 3. Puerto ocupado

```bash
# En macOS, usar host.docker.internal
# En lugar de localhost en variables de entorno
```

### Debugging

```bash
# Ver todos los containers
docker ps

# Ver logs específicos
docker logs <container-name>

# Ejecutar comandos dentro de containers
docker exec -it taskmanager-api sh
docker exec -it taskmanager-db psql -U postgres -d taskmanager

# Verificar networking
docker network ls
docker network inspect task-manager-api_taskmanager-network
```

## ☸️ Kubernetes

Este proyecto está preparado para migrar a Kubernetes con:

- ✅ Health checks configurados
- ✅ Variables de entorno externalizadas
- ✅ Imagen Docker optimizada
- ✅ Separación de concerns
- ✅ Configuración por entorno

### Próximos Pasos

1. **Manifiestos K8s**: Deployments, Services, ConfigMaps
2. **Ingress**: Reemplazar Nginx con Ingress Controller
3. **Secrets**: Manejo seguro de credenciales
4. **Persistent Volumes**: Para PostgreSQL
5. **EKS/AKS**: Deploy en cloud

## 🤝 Contribución

### Desarrollo

```bash
# Fork del proyecto
git clone <tu-fork>
cd task-manager-api

# Crear rama para feature
git checkout -b feature/nueva-funcionalidad

# Hacer cambios y commit
git add .
git commit -m "feat: nueva funcionalidad"

# Push y crear PR
git push origin feature/nueva-funcionalidad
```

### Estándares

- **TypeScript** estricto
- **ESLint + Prettier** para formato
- **Commits** con [Conventional Commits](https://conventionalcommits.org/)
- **Testing** para nuevas funcionalidades

## 📄 Licencia

Este proyecto es de uso educativo para aprender containerización y Kubernetes.

## 👥 Autores

- Tu nombre - Desarrollador principal

## 🙏 Agradecimientos

- Cloud Native Academy por la inspiración del curso
- Comunidad NestJS por la excelente documentación
- Docker y Kubernetes por revolucionar el deployment

---

**¡Happy coding! 🚀**

Para más información sobre Kubernetes y containerización, consulta la documentación oficial de [Kubernetes](https://kubernetes.io/) y [Docker](https://docs.docker.com/).