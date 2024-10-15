provider kubernetes {
  config_path = "../cluster/kubeconfig"
}

resource "kubernetes_manifest" "gitops_application" {
  manifest = yamldecode(<<EOT
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-config
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
    path: applications
    repoURL: https://github.com/crscottau/aro-gitops.git
    targetRevision: HEAD
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true 
EOT
  )

}
