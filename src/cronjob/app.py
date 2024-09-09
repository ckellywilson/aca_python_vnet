import os
import paramiko
import paramiko.ecdsakey

# Define the SSH key file path
ssh_key_path = '/home/vscode/.ssh/id_ed25519'

# Define the SFTP server details
hostname = '104.210.201.253'
port = 22
username = 'vscode'
remote_path = '/home/vscode/sftpfiles/'
local_path = '/home/vscode/sftpfiles/hello.txt'

# Create an SSH client
ssh_client = paramiko.SSHClient()
sftp_client = None

try:
    # Load the SSH key
    private_key = paramiko.Ed25519Key(filename=ssh_key_path)

    # Automatically add the server's host key
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    # Connect to the SFTP server
    ssh_client.connect(hostname, port=port,
                       username=username, pkey=private_key)

    # Create an SFTP client
    sftp_client = ssh_client.open_sftp()

    try:
        # Upload the file
        sftp_client.put(local_path, remote_path)

        print('File uploaded successfully!')
    except Exception as e:
        print(f'An error occurred: {e}')

    finally:
        # Close the SFTP client
        sftp_client.close()

except Exception as e:
    print(f'An error occurred: {e}')

finally:
    # Close the SSH client
    ssh_client.close()
