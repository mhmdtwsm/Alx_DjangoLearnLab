#!/bin/bash

# Ensure target directory exists
mkdir -p blog/templates/blog

# post_list.html
cat > blog/templates/blog/post_list.html << 'EOF'
{% extends "base.html" %}
{% block content %}
  <h1>Blog Posts</h1>
  <ul>
    {% for post in object_list %}
      <li>
        <a href="{% url 'post-detail' post.pk %}">{{ post.title }}</a>
      </li>
    {% empty %}
      <li>No posts available.</li>
    {% endfor %}
  </ul>
  <a href="{% url 'post-create' %}">Create New Post</a>
{% endblock %}
EOF

# post_detail.html
cat > blog/templates/blog/post_detail.html << 'EOF'
{% extends "base.html" %}
{% block content %}
  <h1>{{ object.title }}</h1>
  <p>{{ object.content }}</p>
  <a href="{% url 'post-update' object.pk %}">Edit</a> |
  <a href="{% url 'post-delete' object.pk %}">Delete</a> |
  <a href="{% url 'post-list' %}">Back to List</a>
{% endblock %}
EOF

# post_form.html
cat > blog/templates/blog/post_form.html << 'EOF'
{% extends "base.html" %}
{% block content %}
  <h1>{% if object %}Edit Post{% else %}New Post{% endif %}</h1>
  <form method="post">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit">Save</button>
  </form>
  <a href="{% url 'post-list' %}">Cancel</a>
{% endblock %}
EOF

# post_confirm_delete.html
cat > blog/templates/blog/post_confirm_delete.html << 'EOF'
{% extends "base.html" %}
{% block content %}
  <h1>Delete Post</h1>
  <p>Are you sure you want to delete "{{ object.title }}"?</p>
  <form method="post">
    {% csrf_token %}
    <button type="submit">Confirm</button>
  </form>
  <a href="{% url 'post-detail' object.pk %}">Cancel</a>
{% endblock %}
EOF

echo "CRUD templates created successfully in blog/templates/blog/"

