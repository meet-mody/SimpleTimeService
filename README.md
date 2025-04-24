## Project Structure
```
├── app/                      # Directory for your application's source code
│   ├── .dockerignore         # Specifies intentionally untracked files that Docker should exclude
│   ├── Dockerfile            # Defines the steps to build a Docker image
│   ├── main.py               # Terraform outputs definition file (optional)
│   ├── requirements.txt      # Lists Python package dependencies
│   ├── README.md             # (Optional) Application README file
├── terraform/                # Directory for Terraform infrastructure code
│   ├── main.tf               # Main Terraform configuration file
│   ├── variables.tf          # Terraform variables definition file
│   ├── outputs.tf            # Terraform outputs definition file (optional)
│   ├── terraform.tfvars      # Specifies values for Terraform variables
│   ├── provider.tf           # Configures the Cloud provider
│   ├── README.md             # (Optional) Terraform variables values file                 
├── .gitignore                # Specifies intentionally untracked files that Git should ignore
├── README.md                 # Project README file (this file)
```

## Documentation:

* [Application Documentation](./app/README.md)
* [Terraform Documentation](./terraform/README.md)

## Description

This project automates the deployment of a containerized application to Google Cloud Run, making it accessible to the public internet through a Google Cloud Load Balancer.

* `app/`: This directory is where the source code for application exists. This is a Python Flask application, that shows simple timestamp in UTC zone and IP address of the client making the request.
* `terraform/`: This directory contains the Terraform configuration files that define the infrastructure to be provisioned on Google Cloud Platform (GCP) to run the above application on Cloud Run.

## Important

* Note: This application has been tested on `Linux` and `macOS`. 
* What Could be Improved:
  - Make state file remote and with versioning on GCS.
  - Create a DNS, that allows navigating using a domain instead of IP.