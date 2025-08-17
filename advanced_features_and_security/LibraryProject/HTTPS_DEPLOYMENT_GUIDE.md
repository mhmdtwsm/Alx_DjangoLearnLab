# HTTPS Deployment Guide

This guide provides instructions for deploying the LibraryProject with HTTPS security configurations.

## Overview

This deployment includes the following security enhancements:
- HTTPS redirect for all HTTP requests
- HTTP Strict Transport Security (HSTS)
- Secure cookie configuration
- Security headers for XSS and clickjacking protection
- Content Security Policy (CSP)

## Django Configuration

The following settings have been added to `settings.py`:

### HTTPS Redirect Settings
```python
SECURE_SSL_REDIRECT = True
```
- Redirects all non-HTTPS requests to HTTPS

### HSTS Configuration
```python
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
```
- Instructs browsers to only access via HTTPS for 1 year
- Includes all subdomains in HSTS policy
- Allows preloading in browser HSTS lists

### Secure Cookies
```python
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
```
- Ensures cookies are only transmitted over HTTPS

### Security Headers
```python
X_FRAME_OPTIONS = 'DENY'
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
```
- Prevents clickjacking attacks
- Prevents MIME-sniffing
- Enables XSS filtering

## Web Server Configuration

### Nginx Setup

1. Copy `nginx_https_config.conf` to your Nginx sites directory:
   ```bash
   sudo cp nginx_https_config.conf /etc/nginx/sites-available/libraryproject
   sudo ln -s /etc/nginx/sites-available/libraryproject /etc/nginx/sites-enabled/
   ```

2. Update the configuration file with your domain and certificate paths

3. Test and reload Nginx:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

### Apache Setup

1. Copy `apache_https_config.conf` to your Apache sites directory:
   ```bash
   sudo cp apache_https_config.conf /etc/apache2/sites-available/libraryproject.conf
   sudo a2ensite libraryproject.conf
   ```

2. Enable required Apache modules:
   ```bash
   sudo a2enmod ssl
   sudo a2enmod headers
   sudo a2enmod wsgi
   ```

3. Update the configuration with your paths and reload Apache:
   ```bash
   sudo systemctl reload apache2
   ```

## SSL Certificate Acquisition

### For Development/Testing
Use the provided script to generate self-signed certificates:
```bash
./generate_ssl_certificates.sh
```

### For Production
Use Let's Encrypt for free SSL certificates:

```bash
# Install Certbot
sudo apt update
sudo apt install certbot python3-certbot-nginx  # For Nginx
# OR
sudo apt install certbot python3-certbot-apache  # For Apache

# Obtain certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com  # For Nginx
# OR
sudo certbot --apache -d your-domain.com -d www.your-domain.com  # For Apache
```

## Environment-Specific Settings

### Development
For development, you may want to disable some HTTPS settings:
```python
# In settings_dev.py or when DEBUG=True
if DEBUG:
    SECURE_SSL_REDIRECT = False
    SESSION_COOKIE_SECURE = False
    CSRF_COOKIE_SECURE = False
```

### Production Checklist
- [ ] Valid SSL certificate installed
- [ ] Domain properly configured
- [ ] Firewall allows HTTPS traffic (port 443)
- [ ] Static files served with proper caching headers
- [ ] Database connections secured
- [ ] Environment variables for sensitive settings

## Security Testing

Test your HTTPS configuration using:
- [SSL Labs SSL Server Test](https://www.ssllabs.com/ssltest/)
- [Security Headers](https://securityheaders.com/)
- [Observatory by Mozilla](https://observatory.mozilla.org/)

## Troubleshooting

### Common Issues

1. **Mixed Content Warnings**: Ensure all resources (CSS, JS, images) are loaded via HTTPS
2. **Certificate Errors**: Verify certificate validity and proper installation
3. **Redirect Loops**: Check for conflicting redirect rules in web server and Django
4. **CSP Violations**: Adjust Content-Security-Policy header as needed

### Logs to Check
- Nginx: `/var/log/nginx/error.log`
- Apache: `/var/log/apache2/error.log`
- Django: Check your configured logging

## Maintenance

### Certificate Renewal
Let's Encrypt certificates expire every 90 days. Set up automatic renewal:
```bash
sudo crontab -e
# Add this line:
0 12 * * * /usr/bin/certbot renew --quiet
```

### Security Updates
Regularly update:
- Web server (Nginx/Apache)
- SSL/TLS libraries
- Django and dependencies
- Operating system security patches

## Additional Resources

- [Django Security Documentation](https://docs.djangoproject.com/en/stable/topics/security/)
- [OWASP Security Headers](https://owasp.org/www-project-secure-headers/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
