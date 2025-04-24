output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "public_subnet_names" {
  description = "Names of the public subnets"
  value       = [for subnet in google_compute_subnetwork.public_subnets : subnet.name]
}

output "private_subnet_names" {
  description = "Names of the private subnets"
  value       = [for subnet in google_compute_subnetwork.private_subnets : subnet.name]
}

output "cloud_run_service_url" {
  description = "URL of the deployed Cloud Run service"
  value       = google_cloud_run_service.cloud_run_service.status[0].url
}

output "vpc_connector_name" {
  description = "Name of the Serverless VPC Access connector"
  value       = google_vpc_access_connector.vpc_connector.name
}

output "load_balancer_ip" {
  description = "value of the Load Balancer IP"
  value       = google_compute_global_address.load_balancer_ip.address
}