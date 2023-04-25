// Main script

terraform {
  required_providers {
    securecn = {
      source = "Portshift/securecn"
      version = ">= 1.1.0"
    }
  }
}

// Configure Panoptica provider with keys
provider "securecn" {
 access_key = var.access_key
 secret_key = var.secret_key
}

// Provision K8s cluster in Panoptica
resource "securecn_k8s_cluster" "cluster" {
  kubernetes_cluster_context = var.kubernetes_cluster_context_name
  name = var.environment_name
  ci_image_validation = false
  cd_pod_template = false
  istio_already_installed = false
  connections_control = true
  multi_cluster_communication_support = false
  inspect_incoming_cluster_connections = false
  fail_close = false
  persistent_storage = false
  api_intelligence_dast = true
  install_tracing_support = true
  token_injection = true
}