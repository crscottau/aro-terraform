variable kubeconfig {
  type       = string
  description = "Path to the kubeconfig file extracted from the cluster 'az aro get-admin-kubeconfig'"
  default    = "../cluster/kubeconfig"
}

variable catalogue_name {
  type       = string
  description = "Name of the catalogSource created by the output form the 'oc mirror' plugin"
  default    = "cs-redhat-operator-index"
}
