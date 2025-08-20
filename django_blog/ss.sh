#!/bin/bash
# fix_auth_static.sh - Add static CSS for login and register pages

APP_NAME="blog"

# 1. Create CSS files
mkdir -p $APP_NAME/static/$APP_NAME/css

cat > $APP_NAME/static/$APP_NAME/css/login.css <<'EOF'
body {
    font-family: Arial, sans-serif;
    background-color: #eef2f7;
    margin: 40px;
}
h2 {
    color: #222;
}
form {
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
button {
    background: #4CAF50;
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 5px;
    cursor: pointer;
}
button:hover {
    background: #45a049;
}
EOF

cat > $APP_NAME/static/$APP_NAME/css/register.css <<'EOF'
body {
    font-family: Arial, sans-serif;
    background-color: #f5f9ff;
    margin: 40px;
}
h2 {
    color: #333;
}
form {
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.15);
}
button {
    background: #2196F3;
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 5px;
    cursor: pointer;
}
button:hover {
    background: #1e87d2;
}
EOF

# 2. Update login.html
cat > $APP_NAME/templates/$APP_NAME/login.html <<'EOF'
{% extends "blog/base.html" %}
{% block content %}
  <link rel="stylesheet" href="{% static 'blog/css/login.css' %}">
  <h2>Login</h2>
  <form method="post">
      {% csrf_token %}
      {{ form.as_p }}
      <button type="submit">Login</button>
  </form>
{% endblock %}
EOF

# 3. Update register.html
cat > $APP_NAME/templates/$APP_NAME/register.html <<'EOF'
{% extends "blog/base.html" %}
{% block content %}
  <link rel="stylesheet" href="{% static 'blog/css/register.css' %}">
  <h2>Register</h2>
  <form method="post">
      {% csrf_token %}
      {{ form.as_p }}
      <button type="submit">Register</button>
  </form>
{% endblock %}
EOF

echo "✅ Static files for login and register implemented successfully."

