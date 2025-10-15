# EDDIE - Event-Driven Detector for IoT and Edge

[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](LICENSE)

EDDIE (Event-Driven Detector for IoT and Edge) is an infrastructure-as-code solution for deploying a complete edge computing stack on IoT gateways and edge devices. It automates the provisioning and configuration of containerized ML inference pipelines, data management services, and workflow orchestration tools optimized for resource-constrained edge environments.

## Overview

EDDIE provides a turnkey solution for deploying production-ready machine learning inference at the edge. It combines lightweight Kubernetes (K3s), workflow orchestration (Argo), object storage (MinIO), IoT connectivity (Thingsboard), and integration with CyVerse data infrastructure to enable autonomous, event-driven processing of sensor data.

### Key Features

- **Automated Infrastructure Deployment**: Terraform-based provisioning with Ansible configuration management
- **Edge-Optimized Architecture**: K3s, MinIO, and containerized services designed for resource-constrained devices
- **ML Model Management**: DVC integration for versioned model deployment and updates
- **IoT Platform Integration**: Optional Thingsboard connectivity for telemetry and device management
- **Cloud Storage Integration**: [CyVerse Data Store](https://cyverse.org/data-store0) for cloud storage
- **Workflow Orchestration**: Argo Workflows for event-driven data processing pipelines

### Architecture

The deployed stack includes:

| Component                                  | Purpose                               | Version      |
| ------------------------------------------ | ------------------------------------- | ------------ |
| **Docker**                                 | Container runtime                     | Latest       |
| **K3s**                                    | Lightweight Kubernetes distribution   | v1.30+       |
| **Argo Workflows**                         | Workflow orchestration engine         | v3.4.8+      |
| **MinIO**                                  | S3-compatible object storage          | Configurable |
| **[Thingsboard](https://thingsboard.io/)** | IoT platform for telemetry (optional) | Latest       |
| **rclone**                                 | Cloud storage synchronization         | Latest       |
| **DVC**                                    | Data and model version control        | Latest       |

## Prerequisites

### Deployment Machine Requirements

- **Terraform** >= 1.0
- **Ansible** >= 2.10
- **GoCommands** (gocmd) - CyVerse iRODS client
- **SSH access** to target edge device(s)
- **CyVerse account** with configured data store access

### Target Device Requirements

- **Operating System**: Ubuntu 20.04+ or Debian-based Linux
- **Architecture**: x86_64 or ARM64
- **Memory**: Minimum 4GB RAM (8GB+ recommended)
- **Storage**: Minimum 50GB available disk space
- **Network**: Internet connectivity for package installation and data synchronization
- **SSH**: Enabled with key-based authentication

### Alternative Deployment: CACAO

If your target IoT gateway or edge device has public network accessibility, you can use [CACAO](https://cyverse.org/cacao) (CyVerse's cloud deployment tool) for simplified deployment.

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/cyverse/eddie.git
cd eddie
```

### 2. Configure CyVerse Credentials

Create a `terraform.tfvars` file in the project root:

```hcl
cyverse_user            = "your_cyverse_username"
cyverse_pass            = "your_cyverse_password"
cyverse_asset_config_dir = "/iplant/home/your_username/path/to/configs"
instance_name           = "my-edge-device"
```

**Security Note**: Ensure `terraform.tfvars` is excluded from version control. It is included in `.gitignore` by default.

### 3. Prepare Configuration Files

The `cyverse_asset_config_dir` should contain:

- **Ansible inventory file**: `<instance_name>.yaml` (see [Configuration](#configuration) section)
- **SSH private key**: `ssh_key` (permissions: 0400)

Refer to [README.example-config-file](README.example-config-file) for a complete configuration template.

### 4. Initialize Terraform

```bash
terraform init
```

This will download the required Terraform providers and initialize the working directory.

### 5. Review Deployment Plan

```bash
terraform plan
```

Review the planned changes to ensure they match your expectations.

### 6. Deploy the Stack

```bash
terraform apply
```

Or for automated deployment:

```bash
terraform apply -auto-approve
```

The deployment process will:

1. Download configuration files from CyVerse
2. Install Ansible Galaxy role dependencies
3. Execute the Ansible playbook to configure your edge device
4. Deploy all services to the K3s cluster

**Deployment Time**: Approximately 15-30 minutes depending on network speed and device specifications.

## Configuration

### Ansible Inventory Structure

The inventory file (`configs/<instance_name>.yaml`) defines your edge device and service configurations:

```yaml
all:
  hosts:
    your-edge-device-hostname:
      ansible_user: ubuntu
      ansible_port: 22
  vars:
    # Device Configuration
    device_name: "my-edge-device"

    # CyVerse Integration
    cyverse_user: "your_username"
    cyverse_pass: "your_password"
    cyverse_upload_dir: "/iplant/home/your_username/processed-data"

    # MinIO Object Storage
    minio_version: "RELEASE.2024-07-16T23-46-41Z"
    minio_storage_size: 200 # GB
    minio_bucket_name: "sensor-data"
    minio_access_key: "your-minio-access-key"
    minio_secret_key: "your-minio-secret-key"

    # ML Model Configuration (DVC)
    models_path: "/opt/models"
    dvc_git_models_url: "github.com/your-org/models-repo.git"
    dvc_git_token: "your-github-token"
    dvc_model_path: "models/detector.pt"
    dvc_branch: "main"

    # Thingsboard IoT Platform (Optional)
    thingsboard_host: "thingsboard.example.com"
    thingsboard_device_key: "your-device-key"
    thingsboard_device_secret: "your-device-secret"

    # Container Images
    ULTRALYTICS_IMAGE: "ultralytics/ultralytics:8.1.14"
```

See [README.example-config-file](README.example-config-file) for all available configuration options.

### Advanced Configuration

#### Model Version Override

To deploy a specific model version or branch:

```hcl
model_path_override    = "models/custom-detector.pt"
model_version_override = "v2.1.0"  # Git tag, branch, or commit SHA
```

#### Project Metadata

For integration with CyVerse workbench tools:

```hcl
project    = "My Edge AI Project"
username   = "your_username"
```

## Usage

### Accessing Services

After deployment, services are accessible via kubectl or Traefik ingress:

```bash
# SSH to your edge device
ssh -i configs/ssh_key ubuntu@your-edge-device

# Check cluster status
kubectl get pods -A

# Access MinIO console
kubectl port-forward svc/minio-service 9001:9001 -n default
# Navigate to http://localhost:9001

# View Argo workflows
kubectl port-forward svc/argo-server 2746:2746 -n argo
# Navigate to http://localhost:2746
```

### Deploying ML Workflows

EDDIE uses Argo Workflows for orchestrating ML inference pipelines. Example workflows are deployed automatically and can be customized for your use case.

```bash
# List workflows
argo list -n argo

# Submit a new workflow
argo submit /path/to/workflow.yaml -n argo
```

### Data Management

**Uploading Data to Edge Storage:**

```bash
# Using MinIO client (mc)
mc alias set edgeminio http://<edge-device-ip>:9001 <access-key> <secret-key>
mc cp local-file.jpg edgeminio/sensor-data/
```

**Synchronizing with CyVerse:**

Data is automatically synchronized to CyVerse using rclone based on your configured `cyverse_upload_dir`.

## Troubleshooting

### Connection Issues

**Problem**: Cannot connect to edge device

```bash
# Verify SSH connectivity
ssh -i configs/ssh_key -vvv ubuntu@your-edge-device

# Check SSH key permissions
ls -l configs/ssh_key  # Should show -r--------
```

### Ansible Failures

**Problem**: Ansible playbook fails during deployment

```bash
# Re-run with verbose output
cd ansible
ansible-playbook -i configs/<instance>.yaml --private-key=configs/ssh_key -vvv playbook.yaml
```

### Service Health Checks

```bash
# Check K3s status
systemctl status k3s

# Check all pods
kubectl get pods --all-namespaces

# View pod logs
kubectl logs <pod-name> -n <namespace>
```

### CyVerse Connection Issues

Verify GoCommands configuration:

```bash
cd ansible
cat gocmd.yaml  # Check credentials
gocmd -c gocmd.yaml ls /iplant/home/<username>
```

## Project Structure

```
eddie/
├── ansible/                  # Ansible automation
│   ├── playbook.yaml        # Main playbook
│   ├── requirements.yaml    # Ansible Galaxy dependencies
│   ├── roles/               # Service-specific roles
│   │   ├── argo/           # Argo Workflows deployment
│   │   ├── eddie/          # EDDIE core components
│   │   ├── k8s_tools/      # Kubernetes tooling
│   │   ├── minio/          # MinIO object storage
│   │   ├── rclone/         # Cloud sync configuration
│   │   ├── thingsboard/    # Thingsboard IoT platform
│   │   └── traefik/        # Traefik ingress controller
│   └── init.sh             # Initialization script
├── .cacao/                  # CACAO deployment metadata
├── main.tf                  # Terraform main configuration
├── inputs.tf                # Terraform input variables
├── terraform.tfvars-example # Example Terraform variables
├── README.example-config-file # Example Ansible inventory
└── LICENSE                  # BSD 3-Clause License
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes with descriptive messages
4. Test your changes thoroughly
5. Submit a pull request

For bug reports and feature requests, please use the [GitHub Issues](https://github.com/cyverse/eddie/issues) page.

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

This project is funded by:

- **CyVerse** - Cyberinfrastructure for the Life Sciences, [https://www.cyverse.org]
- **NSF COALESCE** - COntext-Aware LEarning for Sustainable CybEr-agricultural (COALESCE) systems [https://sites.google.com/view/coalescepreview]

## Support

For questions and support:

- **Documentation**: [CyVerse Learning Center](https://learning.cyverse.org)
- **Issues**: [GitHub Issues](https://github.com/cyverse/eddie/issues)
- **Community**: [CyVerse User Forum](https://forum.cyverse.org)

## Citation

If you use EDDIE in your research, please cite:

```bibtex
@software{eddie2024,
  title = {EDDIE: Event-Driven Detector for IoT and Edge},
  author = {CyVerse},
  year = {2024},
  url = {https://github.com/cyverse/eddie},
  license = {BSD-3-Clause}
}
```
