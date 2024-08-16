# eddie
This repo is for the public version of the Event-Driven Detector for IOT and Edge (EDDIE). 

# Instructions
## Pre-requisites

You will need terraform and Ansible installed on the deployment machine. You can also use CACAO, if the target IoT Gateway or device has public access.

## Installation

1. create a file called `terraform.tfvars` with the following content:
```
cyverse_user="myusername"
cyverse_asset_config_dir="/iplant/home/some/dir/to/config"
```
1. `terraform init`
3. `terraform apply -auto-approve`

#