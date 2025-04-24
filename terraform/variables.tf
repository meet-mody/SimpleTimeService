variable "gcp_project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
  default     = "your-gcp-project-id" # Update this with your project ID
}

variable "gcp_region" {
  description = "The region to deploy resources in"
  type        = string
  default     = "us-central1"
}

variable "vpc_network_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "my-vpc-network"
}

variable "vpc_connector_name" {
  description = "The name of the VPC connector"
  type        = string
  default     = "my-vpc-connector"
}

variable "cloud_run_image" {
  description = "The Docker image to deploy to Cloud Run"
  type        = string
  default     = "gcr.io/cloudrun/container:latest" # Update this with your container image
}

variable "cloud_run_service_name" {
  description = "The name of the Cloud Run Service"
  type        = string
  default     = "simple-time-service" # Update this with your container image
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for the public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"] # Example values, update in tfvars
}

variable "private_subnet_cidrs" {
  description = "CIDR ranges for the private subnets"
  type        = list(string)
  default     = ["10.0.2.0/28", "10.0.3.0/28"] # Example values, update in tfvars
}

variable "load_balancer_ip_name" {
  description = "The name of the Load Balancer IP"
  type        = string
  default     = "cloud-run-lb-ip"
}

variable "cloud_run_neg_name" {
  description = "The name of the Network Endpoint Group for Cloud Run"
  type        = string
  default     = "cloud-run-neg"
}

variable "cloud_run_backend_name" {
  description = "The name of the Backend Service for Cloud Run"
  type        = string
  default     = "cloud-run-backend"
}

variable "cloud_run_url_map_name" {
  description = "The name of the URL Map for Cloud Run"
  type        = string
  default     = "cloud-run-url-map"
}

variable "cloud_run_http_proxy_name" {
  description = "The name of the HTTP Proxy for Cloud Run"
  type        = string
  default     = "cloud-run-http-proxy"
}

variable "cloud_run_fw_rule_name" {
  description = "The name of the forwarding rule for Cloud Run"
  type        = string
  default     = "cloud-run-forwarding-rule"
}

