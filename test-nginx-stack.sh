#!/bin/bash

BASE_URL="http://localhost"
API_URL="http://localhost:3000"

echo "🧪 Testing Complete Docker Stack with Nginx..."
echo "=============================================="

# 1. Container Status
echo "1. Container Status:"
docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}" | grep taskmanager
echo ""

# 2. Landing Page
echo "2. Nginx Landing Page:"
curl -s $BASE_URL/ | jq '.' || curl -s $BASE_URL/
echo -e "\n"

# 3. Health Checks
echo "3. Health Checks:"
echo "   Via Nginx (Port 80):"
curl -s $BASE_URL/health | jq '.' || curl -s $BASE_URL/health
echo ""
echo "   Direct API (Port 3000):"
curl -s $API_URL/api/health | jq '.' || curl -s $API_URL/api/health
echo -e "\n"

# 4. Register User
echo "4. Registering User via Nginx:"
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "nginx-test@example.com",
    "password": "123456",
    "name": "Nginx Test User"
  }')

echo $REGISTER_RESPONSE | jq '.' || echo $REGISTER_RESPONSE
echo ""

# 5. Extract Token
if echo $REGISTER_RESPONSE | grep -q "access_token"; then
    TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.access_token' 2>/dev/null || echo $REGISTER_RESPONSE | sed 's/.*"access_token":"\([^"]*\)".*/\1/')
    echo "✅ Token extracted: ${TOKEN:0:50}..."
    echo ""
    
    # 6. Create Tasks
    echo "5. Creating Tasks via Nginx:"
    TASK1=$(curl -s -X POST $BASE_URL/api/tasks \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d '{
        "title": "Test Docker Stack",
        "description": "Nginx + API + PostgreSQL + Redis"
      }')
    
    TASK2=$(curl -s -X POST $BASE_URL/api/tasks \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d '{
        "title": "Learn Kubernetes",
        "description": "Next step in the journey"
      }')
    
    echo "Task 1:" && (echo $TASK1 | jq '.' || echo $TASK1)
    echo "Task 2:" && (echo $TASK2 | jq '.' || echo $TASK2)
    echo ""
    
    # 7. List Tasks
    echo "6. Listing Tasks via Nginx:"
    curl -s -X GET $BASE_URL/api/tasks \
      -H "Authorization: Bearer $TOKEN" | jq '.' || curl -s -X GET $BASE_URL/api/tasks -H "Authorization: Bearer $TOKEN"
    echo -e "\n"
    
    # 8. Get Stats
    echo "7. Task Statistics via Nginx:"
    curl -s -X GET $BASE_URL/api/tasks/stats \
      -H "Authorization: Bearer $TOKEN" | jq '.' || curl -s -X GET $BASE_URL/api/tasks/stats -H "Authorization: Bearer $TOKEN"
    echo -e "\n"
    
    # 9. Update Task
    TASK_ID=$(echo $TASK1 | jq -r '.id' 2>/dev/null || echo $TASK1 | sed 's/.*"id":"\([^"]*\)".*/\1/')
    if [ "$TASK_ID" != "null" ] && [ ! -z "$TASK_ID" ]; then
        echo "8. Updating Task $TASK_ID to completed:"
        curl -s -X PATCH $BASE_URL/api/tasks/$TASK_ID \
          -H "Content-Type: application/json" \
          -H "Authorization: Bearer $TOKEN" \
          -d '{"status": "completed"}' | jq '.' || curl -s -X PATCH $BASE_URL/api/tasks/$TASK_ID -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"status": "completed"}'
        echo ""
    fi
    
else
    echo "❌ Registration failed. Response:"
    echo $REGISTER_RESPONSE
fi

echo "✅ Nginx Stack Testing Completed!"
echo ""
echo "🔗 Available Endpoints:"
echo "   Landing:     http://localhost/"
echo "   Health:      http://localhost/health"
echo "   API:         http://localhost/api/*"
echo "   Direct API:  http://localhost:3000/api/*"