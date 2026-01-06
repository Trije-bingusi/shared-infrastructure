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
      db_host = module.postgres.fqdn
      db_user = module.postgres.administrator_login
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
