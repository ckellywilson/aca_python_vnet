prefix            = "rheem"
location          = "southcentralus"
subscription_id   = "494116cb-e794-4266-98e5-61c178d62cb4"
vm_admin_username = "vscode"
ssh_key_file = "~/.ssh/id_ed25519.pub"
deployment_visibility = "Public" # "Public" or "Private"
py_sample_image = "py-sample:latest"
tags = {
  environment = "dev"
  owner       = "rheem"
}
