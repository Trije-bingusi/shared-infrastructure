# Creates Kubernetes resources that will be shared among microservices,
# including: namespaces, ingress controller, secrets for database access,
# keycloak for identity management 

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
  version    = var.k8s_ingress_chart_version

  values = [
    file("${path.module}/k8s/ingress-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace_v1.ingress
  ]
}

# Retrieve the external IP of the ingress controller
data "kubernetes_service_v1" "ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace_v1.ingress.metadata[0].name
  }

  depends_on = [helm_release.ingress_nginx]
}

locals {
  k8s_ingress_ip = try(
    data.kubernetes_service_v1.ingress.status[0].load_balancer[0].ingress[0].ip,
    "Pending IP assignment (rerun apply later)"
  )
}

# TLS certificate manager
resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.3"

  set = [{
    name  = "installCRDs"
    value = "true"
  }]
}

resource "kubectl_manifest" "letsencrypt_issuer" {
  yaml_body = file("${path.module}/k8s/cluster-issuer.yaml")

  depends_on = [
    helm_release.cert_manager
  ]
}

resource "kubectl_manifest" "nip_tls" {
  yaml_body = templatefile("${path.module}/k8s/certificate.yaml", {
    name      = var.k8s_tls_certificate_name
    namespace = kubernetes_namespace_v1.microservices.metadata[0].name
    hostname  = "${local.k8s_ingress_ip}.nip.io"
  })

  depends_on = [
    kubectl_manifest.letsencrypt_issuer
  ]
}

# Keycloak for identity management
resource "kubernetes_namespace_v1" "keycloak" {
  metadata {
    name = var.k8s_keycloak_namespace
  }
}

resource "random_password" "keycloak_admin" {
  length           = 16
  special          = true
  override_special = "_-!@#"
}

resource "kubernetes_secret_v1" "keycloak_db" {
  metadata {
    namespace = kubernetes_namespace_v1.keycloak.metadata[0].name
    name      = "keycloak-db"
  }

  data = {
    password = module.postgres.administrator_password
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "keycloak_admin" {
  metadata {
    namespace = kubernetes_namespace_v1.keycloak.metadata[0].name
    name      = "keycloak-admin"
  }

  data = {
    password = random_password.keycloak_admin.result
  }

  type = "Opaque"
}

resource "azurerm_postgresql_flexible_server_database" "keycloak" {
  name      = "keycloakdb"
  server_id = module.postgres.id
  charset   = "UTF8"
}

resource "helm_release" "keycloak" {
  name       = "keycloak"
  namespace  = kubernetes_namespace_v1.keycloak.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "keycloak"
  version    = var.k8s_keycloak_chart_version

  values = [
    templatefile("${path.module}/k8s/keycloak-values.yaml", {
      db_host    = module.postgres.fqdn
      db_user    = module.postgres.administrator_login
      hostname   = "${local.k8s_ingress_ip}.nip.io"
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.keycloak,
    kubernetes_secret_v1.keycloak_db,
    kubernetes_secret_v1.keycloak_admin,
    azurerm_postgresql_flexible_server_database.keycloak,
    helm_release.ingress_nginx
  ]
}

# Monitoring stack (Prometheus + Grafana)
module "monitoring" {
  source = "../../modules/k8s/monitoring"

  namespace        = "monitoring"
  chart_version    = "80.13.2"
  retention        = "7d"

  grafana_path = "/grafana"
  grafana_ingress = {
    class_name = "nginx"
    host = "${local.k8s_ingress_ip}.nip.io"
  }
  
  grafana_additional_data_sources = [{
    name = "Loki"
    type = "loki"
    url  = module.logging.loki_url
    json_data = {
      maxLines = 1000
      timeout  = 60
    }
  }]

  service_monitor = {
    port = "http"
    interval = "30s"
    metrics_path = "/metrics"
    namespaces = [
      kubernetes_namespace_v1.microservices.metadata[0].name
    ]
  }
}

# Logging stack (Loki + Promtail)
module "logging" {
  source = "../../modules/k8s/logging"

  namespace = "monitoring"
  retention = "7d"
}

# Messaging system (NATS)
module "nats" {
  source = "../../modules/k8s/nats"

  namespace = "nats"
  replicas  = 3
}
