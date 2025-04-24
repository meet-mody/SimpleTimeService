# Initiate APIs and Create Resources for a Publicly Accessible Cloud Run Service on GCP

This Terraform configuration automates the setup of essential Google Cloud Platform (GCP) resources to deploy a containerized application on Cloud Run and make it publicly accessible via a Load Balancer.

## Overview

This configuration performs the following actions:

1.  **Enables Required GCP APIs:** Ensures necessary GCP services like Compute Engine, VPC Access, Network Services, Cloud Resource Manager, and Cloud Run are enabled in your project.
2.  **Creates a VPC Network:** Sets up a Virtual Private Cloud (VPC) network to provide network isolation for your resources.
3.  **Creates Public Subnets:** Defines public subnets within the VPC network for resources that might need direct internet access (though not directly used by Cloud Run in this configuration).
4.  **Creates Private Subnets:** Defines private subnets within the VPC network, crucial for the Serverless VPC Access connector.
5.  **Creates a Serverless VPC Access Connector:** Provisions a connector that allows your Cloud Run service to communicate with resources within your VPC network.
6.  **Deploys a Cloud Run Service:** Deploys your containerized application to Cloud Run. It configures the service to only accept internal and Cloud Load Balancing traffic and uses the VPC Access connector for egress traffic.
7.  **Sets IAM Permissions for Cloud Run:** Grants public access to invoke the Cloud Run service but for sure via LoadBalancer.
8.  **Creates a Load Balancer IP:** Reserves a static public IP address for the Load Balancer.
9.  **Creates a Serverless NEG:** Creates a Network Endpoint Group (NEG) that points to your Cloud Run service. This is essential for integrating Cloud Run with the Load Balancer.
10. **Creates a Backend Service:** Defines a backend service for the Load Balancer, routing traffic to the Serverless NEG.
11. **Creates a URL Map:** Configures a URL map to define routing rules for incoming HTTP(S) requests (in this case, a simple default route).
12. **Creates a Target HTTP Proxy:** Sets up an HTTP proxy to forward requests to the URL map.
13. **Creates a Global Forwarding Rule:** Defines the rule that directs incoming HTTP traffic on port 80 to the target HTTP proxy using the reserved public IP address.
14. **Waits for Load Balancer Health:** Includes a `null_resource` with a local-exec provisioner to poll the Load Balancer's public IP until it becomes healthy, ensuring the setup is complete and the service is reachable.

## Prerequisites

* **Terraform Installed:** Ensure you have Terraform installed on your local machine or in your CI/CD environment.
* **GCP Project Setup:** You have a Google Cloud Platform project created and configured with the project. 
* **GCP Credentials Configured:** Your Terraform environment is authenticated to your GCP project (e.g. Google Cloud CLI). 

    1. Install Google Cloud CLI using documentation here: https://cloud.google.com/sdk/docs/install.
    2. Run the command `gcloud auth login --update-adc`. This should open a web browser to login with your google credentials.
    3. Make sure you are the `Owner` or `Editor` to the project you are deploying the infra to.

* **Container Image Available:** You have a container image pushed to a container registry (like Google Container Registry or Artifact Registry) that Cloud Run can deploy. By default it will use an image from my registry (i.e. `docker.io/meet19796/time-service:latest`)

## Variables

The following variables are used in this configuration. You will need to define these in a `terraform.tfvars` file or pass them as command-line arguments.

| Name                       | Description                                      | Type         | Default                                     |
| -------------------------- | ------------------------------------------------ | ------------ | ------------------------------------------- |
| `gcp_project_id`           | The ID of your GCP project.                      | string       |                                             |
| `gcp_region`               | The GCP region to deploy resources in.           | string       | `"us-central1"`                             |
| `vpc_network_name`         | The name for the VPC network.                    | string       | `"my-vpc-network"`                          |
| `public_subnet_cidrs`      | A list of CIDR blocks for public subnets.        | list(string) | `["10.0.0.0/28", "10.0.1.0/28"]`            |
| `private_subnet_cidrs`     | A list of CIDR blocks for private subnets.       | list(string) | `["10.0.2.0/28", "10.0.3.0/28"]`            |
| `vpc_connector_name`       | The name for the Serverless VPC Access connector.| string       | `"my-vpc-connector"`                        |
| `cloud_run_service_name`   | The name for the Cloud Run service.              | string       | `"simple-time-service"`                     |
| `cloud_run_image`          | The Docker image to deploy to Cloud Run.         | string       | `"docker.io/meet19796/time-service:latest"` |
| `load_balancer_ip_name`    | The name for the static Load Balancer IP.        | string       | `"cloud-run-lb-ip"`                         |
| `cloud_run_neg_name`       | The name for the Serverless NEG.                 | string       | `"cloud-run-neg"`                           |
| `cloud_run_backend_name`   | The name for the Load Balancer backend service.  | string       | `"cloud-run-backend"`                       |
| `cloud_run_url_map_name`   | The name for the Load Balancer URL map.          | string       | `"cloud-run-url-map"`                       |
| `cloud_run_http_proxy_name`| The name for the Load Balancer HTTP proxy.       | string       | `"cloud-run-http-proxy"`                    |
| `cloud_run_fw_rule_name`   | The name for the Global Forwarding Rule.         | string       | `"cloud-run-forwarding-rule"`               |

## Usage

1.  **Clone the repository (or create a new directory):**
    ```bash
    git clone https://github.com/meet-mody/SimpleTimeService.git
    cd SimpleTimeService/terraform/
    ```

2.  **Update the `terraform.tfvars` file if configuration change is needed:**
    ```terraform
    gcp_project_id            = "your-gcp-project-id" # <-- Replace with your actual GCP project ID
    gcp_region                = "us-central1"
    vpc_network_name          = "my-vpc-network"
    vpc_connector_name        = "my-vpc-connector"
    cloud_run_image           = "docker.io/meet19796/time-service:latest" # <-- Replace with your container image
    cloud_run_service_name    = "simple-time-service"
    public_subnet_cidrs       = ["10.0.0.0/28", "10.0.1.0/28"]
    private_subnet_cidrs      = ["10.0.2.0/28", "10.0.3.0/28"] # <-- Using 28 netmask for VPC Serverless Connector
    load_balancer_ip_name     = "cloud-run-lb-ip"
    cloud_run_neg_name        = "cloud-run-neg"
    cloud_run_backend_name    = "cloud-run-backend"
    cloud_run_url_map_name    = "cloud-run-url-map"
    cloud_run_http_proxy_name = "cloud-run-http-proxy"
    cloud_run_fw_rule_name    = "cloud-run-forwarding-rule"
    ```
    **Note:** Replace the placeholder values with your actual GCP project ID, desired region, network names, subnet CIDR blocks, container image, and other resource names.

3.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

4.  **Plan the changes:**
    ```bash
    terraform plan
    ```
    Review the output to ensure the changes are as expected.

5.  **Apply the configuration:**
    ```bash
    terraform apply -auto-approve
    ```
    Terraform will now provision the resources in your GCP project.

6.  **Access your Cloud Run service:** Once the `terraform apply` command completes successfully and the "Load Balancer is healthy." message appears, you can access your publicly deployed Cloud Run service using the IP address created by the `google_compute_global_address.load_balancer_ip` resource. You can find this IP address in the Terraform output.

## Destroying the Resources

To remove all the resources created by this configuration, run the following command:

```bash
terraform destroy -auto-approve