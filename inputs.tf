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