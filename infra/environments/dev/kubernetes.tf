# Creates Kubernetes resources that will be shared among microservices
# (e.g., namespaces, ingress controller, secrets for database access)

# Namespace for microservices
resource "kubernetes_namespace_v1" "microservices" {
  metadata {
    name = var.k8s_namespace
  }
}

# Database server URL secret
resource "kubernetes_secret_v1" "db_url" {
  metadata {
    namespace = kubernetes_namespace_v1.microservices.metadata[0].name
    name      = var.k8s_db_secret_name
  }

  data = {
    "DATABASE_BASE_URL" = module.postgres.url
  }

  type = "Opaque"
}

# Ingress controller (NGINX)
resource "kubernetes_namespace_v1" "ingress" {
  metadata {
    name = var.k8s_ingress_namespace
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  namespace  = kubernetes_namespace_v1.ingress.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.14.1"

  values = [
    file("${path.module}/k8s/ingress-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace_v1.ingress
  ]
}
