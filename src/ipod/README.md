## About

Sample Flask app with SQLAlchemy and MySQL DB. It uses Cups to print page to PDF.

## Setting up dependencies

# Debugging

To debug with file based DB just debug in VS Code or run `python app.py`

## Azure MySQL

Create file `.env` with contents:

```env
MYSQL_DATABASE=ipod_db
MYSQL_USER=ipodadmin
MYSQL_PASSWORD=<mysql-root-password from ipod KV>
MYSQL_HOST=<MYSQL NAME>.mysql.database.azure.com
MYSQL_PORT=3306
MYSQL_SSL_CA=DigiCertGlobalRootCA.crt.pem
IS_PRODUCTION=true
DEBUG=True
FLASK_DEBUG=1
```
and run the app.