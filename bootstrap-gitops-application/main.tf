provider kubernetes {
  config_path = "../cluster/kubeconfig"
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

}
