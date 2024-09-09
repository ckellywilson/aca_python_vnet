import subprocess
import os


def print_file(file_path, host, printer_name):
    lp_command = ["lp", "-h", host, "-d", printer_name, file_path]
    subprocess.run(lp_command)


# Example usage
file_path = os.environ.get('FOLDER_PATH') + '/test.txt'
printer_name = os.environ.get('PRINTER_NAME')
host = os.environ.get('HOST')

print_file(file_path, host, printer_name)
