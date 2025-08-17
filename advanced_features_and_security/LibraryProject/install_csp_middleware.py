#!/usr/bin/env python3
"""
CSP Middleware Installation Script
This script helps install and configure django-csp middleware.
"""

import os
import re

def add_csp_middleware():
    """Add CSP middleware to Django settings."""
    settings_file = 'LibraryProject/settings.py'
    
    if not os.path.exists(settings_file):
        print("Error: settings.py not found!")
        return False
    
    with open(settings_file, 'r') as f:
        content = f.read()
    
    # Check if CSP middleware is already added
    if 'csp.middleware.CSPMiddleware' in content:
        print("CSP middleware already configured!")
        return True
    
    # Find MIDDLEWARE setting
    middleware_pattern = r'MIDDLEWARE\s*=\s*\[(.*?)\]'
    match = re.search(middleware_pattern, content, re.DOTALL)
    
    if match:
        # Add CSP middleware to the list
        middleware_content = match.group(1)
        new_middleware = middleware_content.rstrip() + "\n    'csp.middleware.CSPMiddleware',"
        new_content = content.replace(match.group(1), new_middleware)
        
        # Write back to file
        with open(settings_file, 'w') as f:
            f.write(new_content)
        
        print("✓ CSP middleware added to settings.py")
        return True
    else:
        print("Error: Could not find MIDDLEWARE setting in settings.py")
        return False

def install_requirements():
    """Install security requirements."""
    print("Installing security packages...")
    os.system('pip install django-csp>=3.7')
    print("✓ django-csp installed")

if __name__ == '__main__':
    print("Installing CSP Security Middleware...")
    install_requirements()
    add_csp_middleware()
    print("\nCSP middleware installation complete!")
    print("Restart your Django development server to apply changes.")
