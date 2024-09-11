import paramiko
import paramiko.ecdsakey
import os

# Define the SSH key file path
ssh_key_path = os.getenv('SSH_KEY_PATH')

# Define the SFTP server details
hostname = os.getenv('SFTP_SERVER')
port = os.getenv('SFTP_PORT')
username = os.getenv('SFTP_USERNAME')
remote_path = os.getenv('SFTP_REMOTE_PATH')
local_path = os.getenv('SFTP_LOCAL_PATH')

# print the environment variables
print(f"SSH_KEY_PATH: {ssh_key_path}")
print(f"SFTP_SERVER: {hostname}")
print(f"SFTP_PORT: {port}")
print(f"SFTP_USERNAME: {username}")
print(f"SFTP_REMOTE_PATH: {remote_path}")
print(f"SFTP_LOCAL_PATH: {local_path}")

# Create an SSH client
ssh_client = paramiko.SSHClient()
sftp_client = None

try:
    # Load the SSH key
    private_key = paramiko.RSAKey(filename=ssh_key_path)

    # Automatically add the server's host key
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    # Connect to the SFTP server
    ssh_client.connect(hostname, port=port,
                       username=username, pkey=private_key)

    # Create an SFTP client
    sftp_client = ssh_client.open_sftp()

    try:
        # Loop through files in the local directory
        for file_name in os.listdir(local_path):
            # Get the full path of the file
            file_path = os.path.join(local_path, file_name)

            try:
                # Upload the file
                sftp_client.put(file_path, f"{remote_path}/{file_name}")
                print(f"File '{file_name}' uploaded successfully!")
            except Exception as e:
                print(f"An error occurred while uploading '{file_name}': {e}")
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
