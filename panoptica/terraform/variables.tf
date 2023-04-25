// Panoptica controller variables

variable "access_key" {
  description = "Panoptica Access Key"
  type        = string
  sensitive   = true
}
variable "secret_key" {
  description = "Panoptica Secret Key"
  type        = string
  sensitive   = true
}
variable "environment_name" {
  description = "Name assigned to the environment"
  type        = string
  default     = "kind-demo"
}
// Run "kubectl config current-context"
variable "kubernetes_cluster_context_name" {
  description = "Name of the Kubernetes cluster context used to connect to the API"
  type        = string
  default     = "kind-demo"
}
