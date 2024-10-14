provider "helm" {
  kubernetes {
    config_path = "../cluster/kubeconfig"
  }
}

resource "helm_release" "openshift-gitops-application" {
  name       = "openshift-gitops-application"

  repository = "http://bootstrap.gpslab.cbr.redhat.com/helm"
  chart      = "openshift-gitops-application"

  set {
    name  = "redhat_catalogue_source"
    value = "cs-redhat-operator-index"
  }
}
