variable application_name {
  type        = string
  description = "GitOps application of applications name for cluster config"
  default = "cluster-config"
}

variable application_repo {
  type    = string
  description = "Repo contaoining the application GitOps YAML" 
  default = "https://github.com/crscottau/aro-gitops.git"
}

variable application_path {
  type    = string
  description = "Path in the repo to the application GitOps YAML" 
  default = "applications"
}
