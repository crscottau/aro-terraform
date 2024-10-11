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

variable redhat_openshift_provider_id {
  type = string
  description = "Common provider ID for RedHat OpemShift on Azure"
}  

variable "openshift_version" {
  type        = string
  description = "az aro get-versions -l eastus"
  default = "4.15.27"
}

variable region {
  type        = string
  description = "Region"
  default     = "eastus"
}

variable resource_group_name {
  type     = string
  default  = "craig-aro-terraform"
}

variable cluster_name {
  type        = string
  description = "Cluster name"
  default     = "aro"
}

variable domain_name {
  type        = string
  description = "Cluster and domain name"
  default     = "azure.redhatworkshops.io"
}

variable vnet_address_space {
  type        = string
  description = "vnet address space"
  default     = "10.0.0.0/22"
}

variable vnet_main_subnet {
  type        = string
  description = "Control plane node subnet"
  default     = "10.0.0.0/23"
}

variable vnet_compute_subnet {
  type        = string
  description = "Conpute node subnet"
  default     = "10.0.2.0/23"
}

variable pod_cidr {
  type        = string
  description = "Non-routable internal POD IP CIDR"
  default     = "10.128.0.0/14"
}

variable service_cidr {
  type        = string
  description = "Non-routable internal POD IP CIDR"
  default     = "172.30.0.0/16"
}

variable api_server_visibility {
  type        = string
  description = "API server visibility"
  default     = "Public"
}

variable ingress_server_visibility {
  type        = string
  description = "API server visibility"
  default     = "Public"
}

variable control_vm_size {
  type        = string
  description = "Control node VM size"
  default     = "Standard_D8s_v3"
}

variable compute_vm_size {
  type        = string
  description = "compute node VM size"
  default     = "Standard_D4s_v3"
}

variable compute_disk_size {
  type        = number
  description = "Compute node disk size"
  default     = 128
}

variable compute_node_count {
  type        = number
  description = "Compute node count"
  default     = 3
}
