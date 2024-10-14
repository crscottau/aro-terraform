provider "helm" {
  kubernetes {
    config_path = "../cluster/kubeconfig"
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
