resource "null_resource" "my_iot" {
    connection {
        type     = "ssh"
        user     = "${var.ssh_username}"
        host     = "${var.ssh_hostname}"
        port     = "${var.ssh_port}"
    }

    triggers = {
        always_run = "${timestamp()}"
    }

    provisioner "local-exec" {
        command = "echo ansible-galaxy install -r requirements.yaml -f"
        working_dir = "${path.module}/ansible"
    }

    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_SSH_PIPELINING=True ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i hosts.yml --forks=10 playbook.yaml"
        working_dir = "${path.module}/ansible"
    }

    depends_on = [
        local_file.ansible-inventory
    ]
}


resource "local_file" "ansible-inventory" {
    content = templatefile("${path.module}/hosts.yml.tmpl",
    {
        ansible_host = var.ssh_hostname
        ansible_port = var.ssh_port
        ansible_user = var.ssh_username
        
        cyverse_user = var.cyverse_user
        cyverse_pass = var.cyverse_pass
        cyverse_upload_dir = var.cyverse_upload_dir

        minio_endpoint = var.minio_endpoint
        minio_external_url = var.minio_external_url
        minio_alias = var.minio_alias
        minio_access_key = var.minio_access_key
        minio_secret_key = var.minio_secret_key
        minio_bucket_name = var.minio_bucket_name

        slack_webhook = var.slack_webhook

        models_path = var.models_path
        dvc_git_models_url = var.dvc_git_models_url
        dvc_git_token = var.dvc_git_token
        dvc_model_path = var.dvc_model_path
        dvc_remote_storage_name = var.dvc_remote_storage_name
        dvc_remote_user = var.dvc_remote_user != "" ? var.dvc_remote_user : var.cyverse_user
        dvc_remote_pass = var.dvc_remote_pass != "" ? var.dvc_remote_pass : var.cyverse_pass
    })
    filename = "${path.module}/ansible/hosts.yml"
}

