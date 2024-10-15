provider kubernetes {
  config_path = "../cluster/kubeconfig"
}

# Even though these blocks are cut/paste from the "oc mirror" output, 
# Terraform seems to want a variable or it will not pass the validate test
resource "kubernetes_manifest" "imagecontentsourcepolicy1" {
  manifest = yamldecode(<<EOT
apiVersion: operator.openshift.io/v1alpha1
kind: ImageContentSourcePolicy
metadata:
  name: generic-0
spec:
  repositoryDigestMirrors:
  - mirrors:
    - craig.azurecr.io/openshift4/openshift4
    source: registry.redhat.io/openshift4
EOT
  )
}

resource "kubernetes_manifest" "imagecontentsourcepolicy2" {
  manifest = yamldecode(<<EOT
apiVersion: operator.openshift.io/v1alpha1
kind: ImageContentSourcePolicy
metadata:
  labels:
    operators.openshift.org/catalog: "true"
  name: operator-0
spec:
  repositoryDigestMirrors:
  - mirrors:
    - craig.azurecr.io/openshift4/openshift-gitops-1
    source: registry.redhat.io/openshift-gitops-1
  - mirrors:
    - craig.azurecr.io/openshift4/openshift4
    source: registry.redhat.io/openshift4
  - mirrors:
    - craig.azurecr.io/openshift4/rh-sso-7
    source: registry.redhat.io/rh-sso-7
  - mirrors:
    - craig.azurecr.io/openshift4/openshift-logging
    source: registry.redhat.io/openshift-logging
  - mirrors:
    - craig.azurecr.io/openshift4/rhel8
    source: registry.redhat.io/rhel8
EOT
  )
}

# Even though these blocks are cut/paste from the "oc mirror" output, 
# Terraform seems to want a variable or it will not pass the validate test
resource "kubernetes_manifest" "cataloguesource" {
  manifest = yamldecode(<<EOT
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ${var.catalogue_name}
  namespace: openshift-marketplace
spec:
  sourceType: gprc
  image: craig.azurecr.io/openshift4/redhat/redhat-operator-index:v4.15
EOT
  )
}

resource "kubernetes_manifest" "gitops_subscription" {
  manifest = yamldecode(<<EOT
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-gitops-operator
  namespace: openshift-operators
spec:
  channel: latest
  installPlanApproval: Automatic
  name: openshift-gitops-operator
  source: ${var.catalogue_name}
  sourceNamespace: openshift-marketplace
EOT
  )

  depends_on = [ kubernetes_manifest.cataloguesource, kubernetes_manifest.imagecontentsourcepolicy1, kubernetes_manifest.imagecontentsourcepolicy2 ] 

}

resource "kubernetes_manifest" "gitops_application" {
  manifest = yamldecode(<<EOT
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${var.application_name}
  namespace: openshift-gitops
spec:
  destination:
    namespace: openshift-operators
    server: https://kubernetes.default.svc
  project: default
  source:
    directory:
      jsonnet: {}
      recurse: true
    path: ${var.application_path }
    repoURL: ${var.application_repo }
    targetRevision: HEAD
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true 
EOT
  )
  depends_on = [ kubernetes_manifest.gitops_subscription ] 

}
