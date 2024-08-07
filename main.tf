
# resource "local_sensitive_file" "ssh_key_file" {
# #   content_base64  = base64decode(var.sshkey_base64)
#   content_base64  = var.sshkey_base64
#   filename = "${path.module}/ansible/private_ssh_key"
#   file_permission = "0400"
# }

resource null_resource "iot_config_files" {
    triggers = {
        always_run = "${timestamp()}"
    }

    # note, sftp will overwrite existing files
    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = <<EOT

            chmod a+x init.sh
            ./init.sh
            echo 'irods_host: "data.cyverse.org"' >gocmd.yaml
            echo 'irods_port: 1247' >>gocmd.yaml
            echo 'irods_user_name: "${var.cyverse_user}"' >>gocmd.yaml
            echo 'irods_zone_name: "iplant"' >>gocmd.yaml
            echo 'irods_user_password: "${var.cyverse_pass}"' >>gocmd.yaml

            cat gocmd.yaml

            gocmd -c gocmd.yaml get -f ${var.cyverse_asset_config_dir}
            chmod 0400 configs/ssh_key          
        EOT
        working_dir = "${path.module}/ansible"
    }
    # depends_on = [
    #     local_sensitive_file.ssh_key_file
    # ]
}

resource "null_resource" "my_iot" {
    triggers = {
        always_run = "${timestamp()}"
    }

    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = "ansible-galaxy install -r requirements.yaml"
        working_dir = "${path.module}/ansible"
    }

    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = <<EOT
            set -x
            # looping because terraform for_each/fileset not working as expected
            dir=configs
            export ANSIBLE_HOST_KEY_CHECKING=False
            export ANSIBLE_SSH_PIPELINING=True
            export ANSIBLE_CONFIG=ansible.cfg

            # for fn in $dir/*.yaml; do
            echo "processing $fn"
            # note, if connection is localhost then ssh_key is ignored
            ansible-playbook --private-key=configs/ssh_key -i configs/${var.instance_name}.yaml -e model_path_override="$MODEL_PATH_OVERRIDE" -e model_version_override="$MODEL_VERSION_OVERRIDE" --forks=10 playbook.yaml
            # done
        EOT
        working_dir = "${path.module}/ansible"

        environment = {
          MODEL_PATH_OVERRIDE = var.model_path_override
          MODEL_VERSION_OVERRIDE = var.model_version_override
        }
    }

    depends_on = [
        null_resource.iot_config_files
    ]
}

