import os
import paramiko.ed25519key


def print_environment_variables():
    print(f'SFTP_SERVER: {os.getenv("SFTP_SERVER")}')
    print(f'SFTP_PORT: {os.getenv("SFTP_PORT")}')
    print(f'SFTP_USERNAME: {os.getenv("SFTP_USERNAME")}')
    print(f'SFTP_REMOTE_PATH: {os.getenv("SFTP_REMOTE_PATH")}')
    print(f'SFTP_LOCAL_PATH: {os.getenv("SFTP_LOCAL_PATH")}')
    print(f'SFTP_SSH_KEY_PATH: {os.getenv("SFTP_SSH_KEY_PATH")}')


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
        for file_attr in sftp_client.listdir_attr(remote_path):
            file_name = file_attr.filename
            remote_file_path = os.path.join(remote_path, file_name)
            local_file_path = os.path.join(local_path, file_name)
            try:
                sftp_client.get(remote_file_path, local_file_path)
                print(f"File '{file_name}' downloaded successfully!")
            except Exception as e:
                print(f"An error occurred while downloading '{
                      file_name}': {e}")
    except Exception as e:
        print(f'An error occurred: {e}')


def main():
    print_environment_variables()
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

main()