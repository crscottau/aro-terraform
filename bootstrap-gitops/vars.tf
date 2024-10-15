variable catalogue_name {
  type    = string
  default = "cs-redhat-operator-index"
}

variable application_name {
  type    = string
  default = "application_name"
}

variable application_path {
  type    = string
  default = "applications"
}

variable application_repo {
  type    = string
  default = "https://github.com/crscottau/aro-gitops.git"
}

variable operator_name {
  type    = string
  default = "https://github.com/crscottau/aro-gitops.git"
}

variable icsp {
  type    =  string
  default = "ImageContentSourcePolicy"
}
