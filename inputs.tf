variable "ssh_username" {
  type = string
  description = "string, the system username to login to the node"
}

variable "ssh_hostname" {
  type = string
  description = "string, the hostname or ip address"
}

variable "ssh_port" {
  type = number
  description = "number, the port to use for ssh"
  default = 22
}

variable "cyverse_user" {
  type = string
  description = "string, the irods username"
}

variable "cyverse_pass" {
  type = string
  description = "string, the irods username"
}

variable "cyverse_upload_dir" {
  type = string
  description = "string, the directory to upload into cyverse"
}

variable "minio_endpoint" {
  type = string
  description = "string, the minio internal endpoint within k8s"
  default = "minio-service.default:9001"
}

variable "minio_external_url" {
  type = string
  description = "string, the minio url outside of the k8s cluster"
}

variable "minio_alias" {
  type = string
  description = "string, the minio alias"
  default = "myminio"
}

variable "minio_bucket_name" {
  type = string
  description = "string, the minio bucket name"
}

variable "minio_access_key" {
  type = string
  description = "string, the minio access key"
}

variable "minio_secret_key" {
  type = string
  description = "string, the minio secret key"
}

variable "slack_webhook" {
  type = string
  description = "string, if set, will send a slack message to this url"
  default = ""
}

variable "models_path" {
  type = string
  description = "string, the path to the models on the device"
  default = "/opt/models"
}

variable "dvc_git_models_url" {
  type = string
  description = "string, git url to clone for dvc"
  default = ""
}

variable "dvc_git_token" {
  type = string
  description = "string, git token for dvc"
  default = ""
}

variable "dvc_model_path" {
  type = string
  description = "string, path to retrieve within the dvc repo"
}

variable "dvc_remote_storage_name" {
  type = string
  description = "string, name for the dvc remote storage"
  default = ""
}

variable "dvc_remote_user" {
  type = string
  description = "string, if not set, will assume cyverse username"
  default = ""
}

variable "dvc_remote_pass" {
  type = string
  description = "string, if not set, will assume cyverse password"
  default = ""
}