# eddie
This repo is for the public version of the Event-Driven Detector for IOT and Edge (EDDIE). 

# TODO
- [ ] Add task to install k3s
- [ ] Add task to install kubectl
- [ ] Add task to install nats
- [ ] Add task to install minio kubernetes and mc tool
- [ ] Add task to install argo workflows and events
- [ ] Add gocmds and config file

## Instructions

1. create a file called `terraform.tfvars` with the following content:
```
ssh_username="myusername"
ssh_hostname="myhostname"
```
1. `terraform init`
2. `eval ``ssh-agent -s`` `
3. `terraform apply -auto-approve`