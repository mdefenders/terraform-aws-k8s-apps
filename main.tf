resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  create_namespace = true
  atomic           = true
  timeout          = 600
  replace          = true # allow reuse of name if a previous failed release metadata exists
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

# Helm Release for Cluster Autoscaler
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = var.autoscaler_chart_version
  timeout    = 600

  set = [
    { name = "autoDiscovery.clusterName", value = var.eks_cluster_name },
    { name = "awsRegion", value = var.aws_region },
    { name = "rbac.serviceAccount.create", value = "true" },
    { name = "rbac.serviceAccount.name", value = "cluster-autoscaler" },
    { name = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn", value = var.autoscaler_role_arn }
  ]

}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  set = [{
    name  = "args"
    value = "{--kubelet-insecure-tls,--kubelet-preferred-address-types=InternalIP,--metric-resolution=15s}"
  }]
}
