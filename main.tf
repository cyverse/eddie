
resource "local_sensitive_file" "ssh_key_file" {
#   content_base64  = base64decode(var.sshkey_base64)
  content_base64  = var.sshkey_base64
  filename = "${path.module}/ansible/private_ssh_key"
  file_permission = "0400"
}

resource null_resource "iot_config_files" {
    triggers = {
        always_run = "${timestamp()}"
    }

    # note, sftp will overwrite existing files
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = <<EOT
            retries=1
            until [[ $retries -eq 0 ]]; do
                sftp -o StrictHostKeyChecking=no -i private_ssh_key -r ${var.cyverse_user}@data.cyverse.org:${var.cyverse_asset_config_dir} .
                if [[ $? -eq 0 ]]; then
                    break
                fi
                echo "sftp failed, retrying in 5 seconds"
                sleep 5
                ((retries--))
            done
            if [[ $retries -eq 0 ]]; then
                echo "Command failed after 5 retries"
                exit 1
            else
                echo "sftp succeeded"
                echo "list of configurations found"
                ls -laFh configs
            fi
        EOT
        working_dir = "${path.module}/ansible"
    }
    depends_on = [
        local_sensitive_file.ssh_key_file
    ]
}

resource "null_resource" "my_iot" {
    triggers = {
        always_run = "${timestamp()}"
    }

    for_each = fileset("${path.module}/ansible", "configs/*.yaml")
   
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = <<EOT
            set -x
            rm -f hosts.yaml
            ln -s ${each.value} hosts.yaml
            ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_SSH_PIPELINING=True ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i hosts.yaml --forks=10 playbook.yaml
            rm -f hosts.yaml # jic
        EOT
        working_dir = "${path.module}/ansible"
    }

    depends_on = [
        null_resource.iot_config_files, local_sensitive_file.ssh_key_file
    ]

    # provisioner "local-exec" {
    #     command = "echo ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_SSH_PIPELINING=True ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i hosts.yml --forks=10 playbook.yaml"
    #     working_dir = "${path.module}/ansible"
    # }



}

