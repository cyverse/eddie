
resource "local_file" "ssh_key_file" {
  content  = base64decode(var.sshkey_base64)
  filename = "${path.module}/ansible/private_ssh_key"
}

resource null_resource "iot_config_files" {
    triggers = {
        always_run = "${timestamp()}"
    }

    # note, sftp will overwrite existing files
    provisioner "local-exec" {
        command = "sftp -i private_ssh_key -r ${var.cyverse_user}@data.cyverse.org:${var.cyverse_asset_config_dir} ."
        working_dir = "${path.module}/ansible"
    }
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



    # provisioner "local-exec" {
    #     command = "echo ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_SSH_PIPELINING=True ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i hosts.yml --forks=10 playbook.yaml"
    #     working_dir = "${path.module}/ansible"
    # }

    depends_on = [
        null_resource.iot_config_files
    ]

}

