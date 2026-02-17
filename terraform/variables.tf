
#
variable "terraform_state_bucket_name" {
  description = "Bucket for storing the Terraform *.tfstate files."
  type        = string
  default     = "some-random-name-bruvio-1234-prima"
}

variable "env" {}

variable "terraform_lock_table_name" {
  description = "DynamoDB table used to lock Terraform state."
  type        = string
  default     = "some-random-name-bruvio-1234-prima-terraform-lock-table"
}

#

variable "project" {
  description = "name of project"
  type        = string
  default     = "challenge-0"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "create_cluster" {
  type        = bool
  description = "enable provisioning of EKS cluster and VPC"
  default     = false
}

variable "cluster_name" {
  description = "name of the EKS cluster"
  default     = "lallero"
  type        = string
}

variable "service_version" {
  description = "Version of the service to deploy"
  type        = string
  default     = "latest"
}

variable "contact" {
  description = "Contact email"
  type        = string
  default     = ""
}
