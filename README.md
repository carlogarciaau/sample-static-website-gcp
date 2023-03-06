# Sample Static Website in GCP

This project demonstrates how to deploy a simple static website to Google Cloud which includes instructions on deploying the static files as well as provisioning the required infrastructure.

The solution involves the following:
1. Terraform to provision GCP resources as code
2. Static files hosted in a GCS bucket 
3. HTTPS Load Balancing to serve content over HTTPS with CDN enabled
4. Cloud Build to deploy the static files to the GCS bucket

## Pre-requisites
1. A GCP project with billing enabled
2. Terraform CLI (https://developer.hashicorp.com/terraform/downloads)
3. gcloud CLI (https://cloud.google.com/sdk/docs/install). Configure with `gcloud init` and `gcloud auth application-default login`
4. A registered domain for provisioning SSL certificates
5. Update the `terraform.tfvars` file with your own configuration

## How to provision the infrastructure
1. Go to the sample-static-website-gcp/terraform directory
2. Run `terraform init` to initialise the working directory
3. Provision the GCP resources using `terraform fmt/validate/plan/apply`
4. Once terraform completes, it will output the public IP address of the load balancer. Setup an `A record` on your DNS service for the domain in the tfvars file and this IP address. In a production environment this should be handled by Terraform on Cloud DNS or similar. 
5. Certificate provisioning may take up to an hour to complete. Monitor this in [Certificate Manager](https://cloud.google.com/certificate-manager/docs/overview)

## How to deploy the static files to the bucket
1. Go to the sample-static-website-gcp/app directory 
2. Go to IAM and grant the Cloud Build Service Account `compute.urlMaps.invalidateCache` permission. 
3. Run the following command, replacing the BUCKET_NAME value with your own bucket: 
`gcloud builds submit --config=cloudbuild.yaml --substitutions=_BUCKET_NAME="cg-static-files"`. The cache invalidation step may take several minutes to complete.

## Shutting down the infrastructure
1. Go to the sample-static-website-gcp/terraform directory
2. Run `terraform destroy` and review the resources before proceeding.

## Other considerations and possible improvements
Assuming this is a production grade website, some improvements we could explore are:
* Containerisation / microservices architecture - benefits are cost effectiveness due to independent scaling of services, self-contained with their own dependencies enabling multi-team / agile development, and increased resiliency. You could run containers in managed kubernetes services like EKS / GKE or serverless container services like Cloud Run.
* Network segregation - public/private subnets, and using NAT gateways for private workloads that require outbound connectivity.
* Utilise managed DB services like Cloud SQL and scaling with read replicas. 
* CI/CD pipelines that triggers automated tests as early as possible, such as on commits or pull requests. Additional CD improvements could utilise modern gitops CD tools like ArgoCD, where it continuously monitors for drift between what is declared in git and what is actually running in K8s and resolves this automatically. 

