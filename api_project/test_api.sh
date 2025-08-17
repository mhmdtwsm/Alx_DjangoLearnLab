#!/bin/bash

# Test script for the Book API endpoint
echo "🧪 Testing Book API endpoint..."

# Check if server is running
if ! curl -s http://127.0.0.1:8000/api/books/ > /dev/null; then
    echo "❌ Server not responding. Make sure Django development server is running:"
    echo "   python manage.py runserver"
    exit 1
fi

echo "📡 Making API request to http://127.0.0.1:8000/api/books/"
echo "Response:"
curl -s -H "Accept: application/json" http://127.0.0.1:8000/api/books/ | python -m json.tool

echo ""
echo "✅ API test completed!"
