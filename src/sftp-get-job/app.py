import os
import paramiko
import time
from dotenv import load_dotenv
# Load environment variables from a .env file
load_dotenv()


def print_environment_variables():
    print('SFTP_SERVER:', os.getenv('SFTP_SERVER'))
    print('SFTP_PORT:', os.getenv('SFTP_PORT'))
    print('SFTP_USERNAME:', os.getenv('SFTP_USERNAME'))
    print('SFTP_REMOTE_PATH:', os.getenv('SFTP_REMOTE_PATH'))
    print('SFTP_LOCAL_PATH:', os.getenv('SFTP_LOCAL_PATH'))
    print('SFTP_SSH_KEY_PATH:', os.getenv('SFTP_SSH_KEY_PATH'))


def validate_environment_variables():
    print('Validating environment variables...')
    if os.getenv('SFTP_SERVER') is None:
        print('The SFTP_SERVER environment variable is not set!')
        return False
    if os.getenv('SFTP_PORT') is None:
        print('The SFTP_PORT environment variable is not set!')
        return False
    if os.getenv('SFTP_USERNAME') is None:
        print('The SFTP_USERNAME environment variable is not set!')
        return False
    if os.getenv('SFTP_REMOTE_PATH') is None:
        print('The SFTP_REMOTE_PATH environment variable is not set!')
        return False
    if os.getenv('SFTP_LOCAL_PATH') is None:
        print('The SFTP_LOCAL_PATH environment variable is not set or the folder does not exist!')
        return False
    if os.getenv('SFTP_SSH_KEY_PATH') is None or not os.path.exists(os.getenv('SFTP_SSH_KEY_PATH')):
        print('The SFTP_SSH_KEY_PATH environment variable is not set or the file does not exist!')
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
        print('Disconnected from the SFTP server!')
    except Exception as e:
        print(
            f'An error occurred while disconnecting from the SFTP server: {e}')


def download_files(sftp_client, remote_path, local_path):
    try:
        for file_name in sftp_client.listdir(remote_path):
            local_file_path = os.path.join(local_path, file_name)
            remote_file_path = os.path.join(remote_path, file_name)
            try:
                sftp_client.get(remote_file_path, local_file_path)
                print(f"File '{file_name}' downloaded successfully!")
            except Exception as e:
                print(f"An error occurred while downloading '{file_name}': {e}")
    except Exception as e:
        print(f'An error occurred: {e}')


def main():
    print_environment_variables()

    if not validate_environment_variables():
        print('Validation failed')
        return -1

    ssh_client, sftp_client = connect_to_sftp(
        os.getenv('SFTP_SERVER'),
        os.getenv('SFTP_PORT'),
        os.getenv('SFTP_USERNAME'),
        os.getenv('SFTP_SSH_KEY_PATH')
    )

    if sftp_client is not None:
        download_files(sftp_client, os.getenv(
            'SFTP_REMOTE_PATH'), os.getenv('SFTP_LOCAL_PATH'))
        disconnect_from_sftp(ssh_client, sftp_client)


if __name__ == '__main__':
    main()
