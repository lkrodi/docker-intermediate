#!/bin/bash

echo "🔍 Debugging Docker Container..."
echo "================================="

# 1. Ver containers corriendo
echo "1. Containers corriendo:"
docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"
echo ""

# 2. Buscar nuestro container específicamente
CONTAINER_ID=$(docker ps -q --filter "ancestor=task-manager-api:v1.0.0")

if [ -z "$CONTAINER_ID" ]; then
    echo "❌ No se encontró container de task-manager-api corriendo"
    echo "¿Corriste el docker run command?"
    exit 1
fi

echo "✅ Container encontrado: $CONTAINER_ID"
echo ""

# 3. Ver los logs del container
echo "2. Logs del container:"
docker logs --tail 10 $CONTAINER_ID
echo ""

# 4. Ver procesos dentro del container
echo "3. Procesos dentro del container:"
docker exec $CONTAINER_ID ps aux
echo ""

# 5. Verificar que la app esté escuchando en puerto 3000
echo "4. Verificando puerto 3000 dentro del container:"
docker exec $CONTAINER_ID netstat -tlnp | grep 3000 || echo "Puerto 3000 no encontrado"
echo ""

# 6. Test desde dentro del container
echo "5. Test desde DENTRO del container:"
docker exec $CONTAINER_ID curl -s http://localhost:3000/api/health || echo "❌ Health check falló desde dentro"
echo ""

# 7. Ver mapeo de puertos
echo "6. Mapeo de puertos:"
docker port $CONTAINER_ID
echo ""

# 8. Tests desde fuera
echo "7. Tests desde TU máquina:"
echo "Probando puerto 3000..."
curl -s --max-time 2 http://localhost:3000/api/health && echo "✅ Puerto 3000 OK" || echo "❌ Puerto 3000 falló"

echo "Probando puerto 3001..."
curl -s --max-time 2 http://localhost:3001/api/health && echo "✅ Puerto 3001 OK" || echo "❌ Puerto 3001 falló"