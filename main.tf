provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "random_id" "random_16" {
  byte_length = 16 * 3 / 4
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  passwords = {
    admin = random_id.random_16.b64_url
    user  = random_string.suffix.result
  }
}


resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "3.0.0"

  values = [file("${path.module}/values.yaml")]

  set {
    name  = "controller.JCasC.configScripts.securityrealm"
    value = templatefile("${path.module}/jenkins-securityrealm.yaml", local.passwords)
  }

  set {
    name  = "controller.JCasC.configScripts.authorizationstrategy"
    value = file("${path.module}/jenkins-authorizationstrategy.yaml")
  }
}

data "kubernetes_service" "jenkins" {
  metadata {
    name = "jenkins"
  }
  depends_on = [helm_release.jenkins]
}

