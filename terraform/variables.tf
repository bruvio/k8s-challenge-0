


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
