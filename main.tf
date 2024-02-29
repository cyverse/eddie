
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

    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = <<EOT
            set -x
            # looping because terraform for_each/fileset not working as expected
            dir=configs
            ANSIBLE_HOST_KEY_CHECKING=False
            ANSIBLE_SSH_PIPELINING=True
            ANSIBLE_CONFIG=ansible.cfg
            for fn in $dir/*.yaml; do
                echo "processing $fn"
                rm -f hosts.yaml
                ln -s $fn hosts.yaml
                ansible-playbook -i hosts.yaml -e ansible_ssh_private_key_file=private_ssh_key --forks=10 playbook.yaml
            done
        EOT
        working_dir = "${path.module}/ansible"
    }

    depends_on = [
        null_resource.iot_config_files, local_sensitive_file.ssh_key_file
    ]
}

