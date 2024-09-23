import os
import paramiko
from dotenv import load_dotenv
import pandas as pd
import mysql.connector

# Import the `configure_azure_monitor()` function from the
# `azure.monitor.opentelemetry` package.
from azure.monitor.opentelemetry import configure_azure_monitor

# Import the tracing api from the `opentelemetry` package.
from opentelemetry import trace

# Configure OpenTelemetry to use Azure Monitor with the
# APPLICATIONINSIGHTS_CONNECTION_STRING environment variable.
configure_azure_monitor()

# Load environment variables from .env file
load_dotenv()

required_vars = ['MYSQL_DATABASE', 'MYSQL_USER', 'MYSQL_PASSWORD', 'MYSQL_HOST', 'MYSQL_PORT',
                 'SFTP_SSH_KEY_PATH', 'SFTP_SERVER', 'SFTP_PORT', 'SFTP_USERNAME', 'SFTP_REMOTE_PATH', 'SFTP_LOCAL_PATH']


def print_required_vars():
    for var in required_vars:
        value = os.getenv(var)
        print(f"{var}: {value}")


def validate_environment_variables():
    print('Validating environment variables...')
    for var in required_vars:
        if os.getenv(var) is None:
            print(f'The {var} environment variable is not set!')
            return False
    return True


def connect_to_sftp(hostname, port, username, ssh_key_path):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    private_key = paramiko.Ed25519Key(
        filename=os.path.expanduser(ssh_key_path))

    try:
        ssh_client.connect(hostname, port=int(
            port), username=username, pkey=private_key)
        sftp_client = ssh_client.open_sftp()
        return ssh_client, sftp_client
    except Exception as e:
        print(f'An error occurred while connecting to the SFTP server: {e}')
        ssh_client.close()
        return None, None


def disconnect_from_sftp(ssh_client, sftp_client):
    try:
        sftp_client.close()
        ssh_client.close()
    except Exception as e:
        print(
            f'An error occurred while disconnecting from the SFTP server: {e}')


def download_csv_files(sftp_client, remote_path, local_path):
    print(f'Downloading files from {remote_path} to {local_path}...')
    files = sftp_client.listdir(remote_path)
    for file in files:
        if file.endswith('.csv'):
            sftp_client.get(f'{remote_path}/{file}', f'{local_path}/{file}')
            print(f'{file} downloaded successfully')
    print('All files downloaded')


def create_mysql_connection(host_name, user_name, user_password, db_name, db_port, ssl_ca):
    connection = None
    try:
        print(f"Connecting to MySQL DB: {host_name}:{db_port}")
        connection = mysql.connector.connect(
            host=host_name,
            user=user_name,
            passwd=user_password,
            database=db_name,
            port=db_port,
            ssl_ca=ssl_ca
        )
        print("Connection to MySQL DB successful")
    except mysql.connector.Error as e:
        print(f"The error '{e}' occurred")
    return connection


def execute_query(connection, query, data):
    cursor = connection.cursor()
    try:
        cursor.execute(query, data)
        connection.commit()
        print("Query executed successfully")
    except mysql.connector.Error as e:
        print(f"The error '{e}' occurred")


def ensure_table_exists(connection):
    create_table_query = """
    CREATE TABLE IF NOT EXISTS myapp_mymodel (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    """
    execute_query(connection, create_table_query, None)


def insert_csv_data(connection, csv_file):
    df = pd.read_csv(csv_file)
    for index, row in df.iterrows():
        insert_query = """
        INSERT INTO myapp_mymodel (name, description, created_at)
        VALUES (%s, %s, %s)
        """
        data = (row['name'], row['description'], row['created_at'])
        execute_query(connection, insert_query, data)


def main():
    if not validate_environment_variables():
        print_required_vars()
        return

    host_name = os.getenv('MYSQL_HOST')
    user_name = os.getenv('MYSQL_USER')
    user_password = os.getenv('MYSQL_PASSWORD')
    db_name = os.getenv('MYSQL_DATABASE')
    db_port = os.getenv('MYSQL_PORT')
    ssl_ca = os.getenv('MYSQL_SSL_CA')

    ssh_key_path = os.getenv('SFTP_SSH_KEY_PATH')
    sftp_server = os.getenv('SFTP_SERVER')
    sftp_port = os.getenv('SFTP_PORT')
    sftp_username = os.getenv('SFTP_USERNAME')
    sftp_remote_path = os.getenv('SFTP_REMOTE_PATH')
    sftp_local_path = os.getenv('SFTP_LOCAL_PATH')

    ssh_client, sftp_client = connect_to_sftp(
        sftp_server, sftp_port, sftp_username, ssh_key_path)

    if ssh_client is None or sftp_client is None:
        return

    download_csv_files(sftp_client, sftp_remote_path, sftp_local_path)

    connection = create_mysql_connection(
        host_name, user_name, user_password, db_name, db_port, ssl_ca)

    if connection is None:
        return

    ensure_table_exists(connection)

    files = os.listdir(sftp_local_path)
    for file in files:
        if file.endswith('.csv'):
            insert_csv_data(connection, f'{sftp_local_path}/{file}')

    disconnect_from_sftp(ssh_client, sftp_client)
    connection.close()


if __name__ == '__main__':
    main()
