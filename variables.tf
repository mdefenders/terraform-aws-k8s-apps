variable "argocd_chart_version" {
  description = "The Helm release for ArgoCD."
  type        = string
}
variable "appsets_chart_version" {
  description = "The Helm release for AppSets."
  type        = string
}
variable "appset_name" {
  description = "The name of the ArgoCD AppSet to create."
  type        = string
}
variable "github_org" {
  description = "The GitHub organization where the repo is located."
  type        = string
}
variable "app_chart_repo" {
  description = "The GitHub repository where the Helm charts are located."
  type        = string
}
variable "app_chart_name" {
  description = "The name of the Helm chart to deploy."
  type        = string
}
variable "app_chart_version" {
  description = "The version of the Helm chart to deploy."
  type        = string
}
variable "autoscaler_chart_version" {
  description = "The Helm chart version for Cluster Autoscaler"
  type        = string
}
variable "deploy_appsets" {
  description = "Whether to deploy ArgoCD AppSets"
  type        = bool
}
variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}
variable "autoscaler_role_arn" {
  description = "The ARN of the IAM role for the Cluster Autoscaler."
  type        = string
}
variable "aws_region" {
  description = "The AWS region where the EKS cluster is deployed."
  type        = string
}
variable "alb_chart_version" {
  description = "The Helm chart version for AWS Load Balancer Controller"
  type        = string
}
variable "alb_role_arn" {
  description = "The ARN of the IAM role for the AWS Load Balancer Controller."
  type        = string
}
variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster is deployed."
  type        = string
}

variable "ingress_chart_version" {
  description = "The Helm chart version for NGINX Ingress Controller"
  type        = string
}