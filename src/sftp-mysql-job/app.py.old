import MySQLdb
import os
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


def create_connection(host_name, user_name, user_password, db_name, db_portm, ssl_ca):
    connection = None
    try:
        print(f"Connecting to MySQL DB: {host_name}:{db_port}")
        connection = MySQLdb.connect(
            host=host_name,
            user=user_name,
            passwd=user_password,
            db=db_name,
            port=int(db_port),
            ssl={
                'ca': ssl_ca,
            } if ssl_ca else None
        )
        print("Connection to MySQL DB successful")
    except MySQLdb.Error as e:
        print(f"The error '{e}' occurred")
    return connection


def execute_query(connection, query, data):
    cursor = connection.cursor()
    try:
        cursor.execute(query, data)
        connection.commit()
        print("Query executed successfully")
    except MySQLdb.Error as e:
        print(f"The error '{e}' occurred")


# Database connection details
db_name = os.environ.get("MYSQL_DATABASE", "my_database")
user_name = os.environ.get("MYSQL_USER", "my_user")
user_password = os.environ.get("MYSQL_PASSWORD", "my_password")
host_name = os.environ.get("MYSQL_HOST", "127.0.0.1")
db_port = os.environ.get("MYSQL_PORT", "3306")
ssl_ca = os.environ.get("MYSQL_SSL_CA")

# Create a connection to the database
connection = create_connection(host_name, user_name, user_password, db_name, db_port, ssl_ca)

# this is only used in testing - on the server table already exists
create_table_query = """
CREATE TABLE IF NOT EXISTS myapp_mymodel (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
"""
execute_query(connection, create_table_query, ())

# SQL query to insert a new record
insert_query = """
INSERT INTO myapp_mymodel (name, description, created_at)
VALUES (%s, %s, %s)
"""

pod_name = os.environ.get("HOSTNAME", "unknown_pod")
# Data to be inserted
data = ("Value added by JOB", f"Running in {pod_name}", datetime.now())

# Execute the query
execute_query(connection, insert_query, data)
