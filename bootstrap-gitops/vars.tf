variable catalogue_name {
  type    = string
  default = "cs-redhat-operator-index"
}

variable operator_name {
  type    = string
  default = "https://github.com/crscottau/aro-gitops.git"
}

variable icsp {
  type    =  string
  default = "ImageContentSourcePolicy"
}
