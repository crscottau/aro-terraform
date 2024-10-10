variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID (needed with the new Auth method)"
}

variable "client_id" {
  type        = string
  description = "Azure Service Principal/App Registration Client ID"
}

variable "client_secret" {
  type        = string
  description = "Azure Service Principal/App Registration secret"
}

# az account show
variable "tenant_id" {
  type        = string
  description = "Azure Tenant"
}

variable "object_id" {
  type        = string
  description = "Our SP/APP REG Object Id"
}

variable "openshift_version" {
  type        = string
  description = "az aro get-versions -l eastus"
  default     = "4.15.27"
}

variable redhat_openshift_provider_id {
  type        = string
  description = "Common provider ID for RedHat OpemShift on Azure"
}  

variable resource_group_name {
  type        = string
  description = "Resource group to hold the ARO cluster"
  default     = "craig-aro-terraform"
}

variable region {
  type        = string
  description = "Region"
  default     = "eastus"
}