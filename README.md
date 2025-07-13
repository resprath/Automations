# IBM Cloud & Watsonx.data Automation Toolkit


This repository provides a collection of **Terraform** and **Ansible** automation workflows to streamline resource provisioning and Watsonx.data catalog setup on IBM Cloud. It enables consistent, secure, and rapid environment onboarding.

├── main.tf               # IBM Cloud resources: IAM, COS, Secrets Manager, KMS
├── provider.tf           # IBM Cloud provider configuration
├── variables.tf          # Variable definitions
├── versions.tf           # Provider and Terraform versions
└── ansible/
    ├── hosts.inv         # Ansible inventory file
    ├── wxd_create.yaml   # Creates Watsonx.data catalog and sets up permissions
    └── wxd_destroy.yaml  # Cleans up WXD catalog and related resources

# Prerequisites
Before using this automation, ensure you have the following:
IBM Cloud account with required service access
IBM Schematics workspace linked to this GitHub repo
Terraform v1.4+ (managed by Schematics)
Required IAM access to:
Create COS, KMS, Secrets Manager, Event Streams
Assign IAM policies
Register catalogs and buckets in Watsonx.data


In `main.tf`, the first 34 resources are related to IBM cloud resources such as secrets, COS instances, buckets, KMS instance, secrets etc.

Along with the regular Cloud variables ( 34 resources) we have Two Ansible playbooks defined as resources. One is for creating WXD resources and another one for deleting.

Create is a two step with plan and apply.
NOTE : -auto-approve will run the script without waiting for the approval in terms of yes/no.. Be vigilant about what you are about to run.

1) terraform plan  

2) terraform apply -var="create=true" -auto-approve  

#How to Use
🔹 Step 1: Clone the Repository 
git clone https://github.com/resprath/Automations
cd Automations
🔹 Step 2: Create a Schematics Workspace
Go to IBM Cloud Schematics.
Create a new workspace.
Set GitHub as the source control and link this repo.
Set input variables via UI or variables.tf or terraform.tfvars
🔹 Step 3: Configure Variables
Edit terraform.tfvars or define variables in the UI such as 
region            = "us-south"
catalog_name      = "demo-catalog"
catalog_type      = "iceberg"
description       = "Analytics catalog for demo"
bucket_display    = "demo-bucket"
bucket_type       = "primary"
🔹 Step 4: Apply Plan
Run Apply Plan in the Schematics UI. This will:
Provision all required cloud services and Watsonx.data resources

