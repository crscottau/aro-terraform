provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

resource "helm_release" "openshift-gitops" {
  name       = "openshift-gitops"

  repository = "http://bootstrap.gpslab.cbr.redhat.com/helm"
  chart      = "openshift-gitops"

  set {
    name  = "redhat_catalogue_source"
    value = "cs-redhat-operator-index"
  }
}
