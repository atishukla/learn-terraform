output "passwords" {
  value = local.passwords
}

output "jenkins_svc" {
  value = data.kubernetes_service.jenkins.spec.0.port.0.port
}