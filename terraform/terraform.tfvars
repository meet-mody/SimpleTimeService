gcp_project_id         = "your-gcp-project-id" # <-- Replace with your actual GCP project ID
gcp_region             = "us-central1"
vpc_network_name       = "my-vpc-network"
vpc_connector_name     = "my-vpc-connector"
cloud_run_image        = "docker.io/meet19796/time-service:latest" # <-- Replace with your container image
cloud_run_service_name = "simple-time-service"

public_subnet_cidrs  = ["10.0.0.0/28", "10.0.1.0/28"]
private_subnet_cidrs = ["10.0.2.0/28", "10.0.3.0/28"]

load_balancer_ip_name     = "cloud-run-lb-ip"
cloud_run_neg_name        = "cloud-run-neg"
cloud_run_backend_name    = "cloud-run-backend"
cloud_run_url_map_name    = "cloud-run-url-map"
cloud_run_http_proxy_name = "cloud-run-http-proxy"
cloud_run_fw_rule_name    = "cloud-run-forwarding-rule"
