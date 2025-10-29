resource "google_secret_manager_secret" "github_token" {
  secret_id = var.github_token_id
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "github_token_version" {
  secret      = google_secret_manager_secret.github_token.id
  secret_data = var.github_token
}
data "google_secret_manager_secret_version" "github_token" {
  secret  = google_secret_manager_secret.github_token.secret_id
  version = "latest"
}

resource "kubernetes_secret" "argocd_github_token" {
  metadata {
    name      = "mdefenders-github-token"
    namespace = "argocd"
  }
  data = {
    token = data.google_secret_manager_secret_version.github_token.secret_data
  }
  depends_on = [helm_release.argocd]
}

resource "helm_release" "appsets" {
  count            = var.deploy_appsets ? 1 : 0
  name             = "argo-appsets"
  namespace        = "argocd"
  repository       = "https://mdefenders.github.io/helmcharts"
  chart            = "argo-appsets"
  version          = var.appsets_chart_version
  create_namespace = true
  timeout          = 600
  # Use templatefile so ${var.*} placeholders in values.yaml are interpolated
  values = [templatefile("${path.module}/values.yaml", {
    var = {
      appset_name   = var.appset_name
      github_org    = var.github_org
      chart_repo    = var.app_chart_repo
      chart_name    = var.app_chart_name
      chart_version = var.app_chart_version
    }
  })]
  atomic     = true
  depends_on = [helm_release.argocd]
}
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  create_namespace = true
  atomic           = true
  timeout          = 600
  depends_on       = [google_secret_manager_secret_version.github_token_version]
}

resource "helm_release" "gateways" {
  name       = "gke-gateways"
  namespace  = "default"
  repository = "https://mdefenders.github.io/helmcharts"
  chart      = "gke-gateways"
  version    = var.gateways_chart_version
  atomic     = true
  timeout    = 600
  values = [
    yamlencode({
      project          = var.gw_project_id
      gatewayClassName = var.gw_class
    })
  ]
}
