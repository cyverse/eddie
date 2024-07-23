# eddie
This repo is for the public version of the Event-Driven Detector for IOT and Edge (EDDIE). 

# Pre-requisites
- minio installed and object storage configured
- argo installed

# TODO
- [X] Add task to install k3s
- [ ] Add task to install kubectl
- [ ] Add task to install nats
- [ ] Add task to install minio kubernetes and mc tool
- [ ] Add task to install argo workflows and events
- [X] Add gocmds and config file
- [ ] Add destroy playbook
- [X] move sensitive configuration to datastore

## Instructions

1. execute init.sh
```
    ./init.sh
```
1. create a file called `terraform.tfvars` with the following content:
```
cyverse_user="myusername"
cyverse_asset_config_dir="/iplant/home/some/dir/to/config"
```
1. `terraform init`
3. `terraform apply -auto-approve`