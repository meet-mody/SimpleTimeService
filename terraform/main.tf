# Initiate APIs for GCP to create resources
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",              # VPC, subnets, IPs
    "networkservices.googleapis.com",      # NEG
    "cloudresourcemanager.googleapis.com", # IAM binding
    "run.googleapis.com",                  # Cloud Run
    "vpcaccess.googleapis.com",            # Serverless VPC Access Connector
  ])

  service                    = each.key
  project                    = var.gcp_project_id
  disable_on_destroy         = true
  disable_dependent_services = true
  lifecycle {
    prevent_destroy = false
  }
}

# 1. Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_network_name
  auto_create_subnetworks = false
  depends_on              = [google_project_service.required_apis]
}

# 2. Create Public Subnets
resource "google_compute_subnetwork" "public_subnets" {
  count         = length(var.public_subnet_cidrs)
  name          = "public-subnet-${count.index + 1}"
  ip_cidr_range = var.public_subnet_cidrs[count.index]
  network       = google_compute_network.vpc_network.id
  region        = var.gcp_region
}

# 3. Create Private Subnets
resource "google_compute_subnetwork" "private_subnets" {
  count                    = length(var.private_subnet_cidrs)
  name                     = "private-subnet-${count.index + 1}"
  ip_cidr_range            = var.private_subnet_cidrs[count.index]
  purpose                  = "PRIVATE"
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
  region                   = var.gcp_region
}

# 4. Create a Serverless VPC Access connector
resource "google_vpc_access_connector" "vpc_connector" {
  name = var.vpc_connector_name
  subnet {
    name = google_compute_subnetwork.private_subnets[0].name
  }
  region        = var.gcp_region
  min_instances = 2
  max_instances = 3
}

# 5. Deploy a Cloud Run service
resource "google_cloud_run_service" "cloud_run_service" {
  name     = var.cloud_run_service_name
  location = var.gcp_region

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }

  template {
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.vpc_connector.id
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
      }
    }

    spec {
      containers {
        image = var.cloud_run_image
        ports {
          container_port = 8080
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_vpc_access_connector.vpc_connector]
}

# 6. To trigger the Cloud Run service, we need to set up IAM permissions
resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_service.cloud_run_service.location
  service  = google_cloud_run_service.cloud_run_service.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

# 7. Create a Load Balancer IP
resource "google_compute_global_address" "load_balancer_ip" {
  name       = var.load_balancer_ip_name
  project    = var.gcp_project_id
  depends_on = [google_project_service.required_apis]
}

# 8. Create a Serverless NEG (Network Endpoint Group) for Cloud Run
resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  name                  = var.cloud_run_neg_name
  network_endpoint_type = "SERVERLESS"
  region                = var.gcp_region
  cloud_run {
    service = google_cloud_run_service.cloud_run_service.name
  }
}

# 9. Create a Backend Service for the Load Balancer
resource "google_compute_backend_service" "cloud_run_backend" {
  name                  = var.cloud_run_backend_name
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  backend {
    group = google_compute_region_network_endpoint_group.cloud_run_neg.id
  }
}

# 10. Create a Cloud Run URL Map to route traffic to the Backend Service
resource "google_compute_url_map" "cloud_run_url_map" {
  name            = var.cloud_run_url_map_name
  default_service = google_compute_backend_service.cloud_run_backend.self_link
}

# 11. Create a Target HTTP Proxy to route traffic to the URL Map
resource "google_compute_target_http_proxy" "cloud_run_http_proxy" {
  name    = var.cloud_run_http_proxy_name
  url_map = google_compute_url_map.cloud_run_url_map.id
}

# 12. Create a Global Forwarding Rule to route traffic to the Backend Service
resource "google_compute_global_forwarding_rule" "cloud_run_forwarding_rule" {
  name                  = var.cloud_run_fw_rule_name
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.cloud_run_http_proxy.id
  ip_address            = google_compute_global_address.load_balancer_ip.address
  project               = var.gcp_project_id
}

resource "null_resource" "wait_for_lb_health" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for Load Balancer to become healthy..."
      for i in {1..30}; do
        if curl -s --fail http://${google_compute_global_address.load_balancer_ip.address}; then
          echo "Load Balancer is healthy."
          exit 0
        else
          echo "Still waiting..."
          sleep 10
        fi
      done
      echo "Timeout waiting for Load Balancer to become healthy."
      exit 1
    EOT
  }

  depends_on = [google_compute_global_forwarding_rule.cloud_run_forwarding_rule]
}
