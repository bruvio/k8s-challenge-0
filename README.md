## Challenge 0 — Foundation Setup

**Objective:** Establish the base infrastructure and workflows that all subsequent challenges depend on.

### Requirements

Set up an AWS account with a Terraform backend (S3 + DynamoDB for state locking). Create a Git repository with a CI/CD pipeline that runs `terraform validate`, `terraform plan` on PRs, and `terraform apply` on merge to `main`. The pipeline must also lint Python code with `ruff` or `flake8` and run `pytest`.

Provision a VPC with public and private subnets across two availability zones, a NAT gateway, and an EKS cluster (single managed node group, `t3.medium`, 2 nodes). Use Terraform modules to keep the code DRY.

### Deliverables

- Terraform code organised into modules: `networking`, `eks`, `backend`
- CI/CD pipeline definition (`.github/workflows/*.yml` or `.gitlab-ci.yml`)
- A `README.md` explaining how to bootstrap the project from scratch
- A working `kubectl get nodes` output proving cluster connectivity

### Evaluation Criteria

- Terraform state is remote and locked
- Secrets (AWS credentials) are handled via CI/CD variables, never committed
- Code passes `terraform validate` and `tflint`
- EKS cluster is reachable and nodes are `Ready`