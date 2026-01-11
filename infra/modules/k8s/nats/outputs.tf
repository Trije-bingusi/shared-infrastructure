output "url" {
  description = "The NATS server URL."
  value       = helm_release.nats.status  
}
