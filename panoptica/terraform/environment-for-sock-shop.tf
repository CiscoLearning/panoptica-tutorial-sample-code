resource "securecn_environment" "sock-shop-testing" {

  name = "kind-demo-sock-shop-testing"
  description = "testing environment"

  kubernetes_environment {
    cluster_name = securecn_k8s_cluster.cluster.name
    namespaces_by_names = ["sock-shop"]
  }
}
