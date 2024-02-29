variable "cyverse_user" {
  type = string
  description = "string, the cyverse username"
}

variable "cyverse_asset_config_dir" {
  type = string
  description = "string, path to the cyverse asset configuration directory"
}

# The following is minimally required for cacao
variable "username" {
  type        = string
  description = "name of user"
}

# this is minimumally needed
variable "instance_name" {
  type = string
  description = "name of instance"
}

# this is needed for ionosphere
variable "power_state" {
  type = string
  description = "power state of instance"
  default = "active"
}

# this is needed to render in ionosphere
variable "project" {
  type = string
  description = "project name"
  default = ""
}