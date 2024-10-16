provider kubernetes {
  config_path = "../cluster/kubeconfig" # Will not accept a variable, hopefully ADO allows passing files between steps
}

# The GitOps application needs to be created in a separate step as the CRDs are not created until 
# the Operator is installed and so the plan fails.
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
    path: ${var.application_path}
    #repoURL: https://github.com/crscottau/aro-gitops.git
    repoURL: ${var.application_repo}
    targetRevision: HEAD
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true 
EOT
  )

}
