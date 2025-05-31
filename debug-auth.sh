#!/bin/bash

BASE_URL="http://localhost:3000/api"

echo "🔍 Debugging Authentication..."
echo "==============================="

# 1. Health check first
echo "1. Health Check:"
curl -s $BASE_URL/health
echo -e "\n\n"

# 2. Try to login (this will give us a fresh token)
echo "2. Getting fresh token..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "123456"
  }')

echo "Login response:"
echo $LOGIN_RESPONSE
echo -e "\n"

# Check if login was successful
if echo $LOGIN_RESPONSE | grep -q "access_token"; then
    TOKEN=$(echo $LOGIN_RESPONSE | sed 's/.*"access_token":"\([^"]*\)".*/\1/')
    echo "✅ Token extracted: ${TOKEN:0:50}..."
    echo -e "\n"
    
    # 3. Test protected endpoint
    echo "3. Testing protected endpoint (GET /tasks):"
    TASKS_RESPONSE=$(curl -s -X GET $BASE_URL/tasks \
      -H "Authorization: Bearer $TOKEN")
    
    echo "Tasks response:"
    echo $TASKS_RESPONSE
    echo -e "\n"
    
    # 4. Try creating a task
    echo "4. Creating a task:"
    CREATE_RESPONSE=$(curl -s -X POST $BASE_URL/tasks \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d '{
        "title": "Test Task",
        "description": "Testing authentication"
      }')
    
    echo "Create task response:"
    echo $CREATE_RESPONSE
    
else
    echo "❌ Login failed. Response:"
    echo $LOGIN_RESPONSE
    echo -e "\n"
    
    echo "Let's try registering a new user:"
    REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/auth/register \
      -H "Content-Type: application/json" \
      -d '{
        "email": "debug@example.com",
        "password": "123456",
        "name": "Debug User"
      }')
    
    echo "Register response:"
    echo $REGISTER_RESPONSE
fi