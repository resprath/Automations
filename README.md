# IBM Cloud & Watsonx.data Automation Toolkit


This repository provides a collection of **Terraform** and **Ansible** automation workflows to streamline resource provisioning and Watsonx.data catalog setup on IBM Cloud. It enables consistent, secure, and rapid environment onboarding.

##  Repository Structure

```text
.
├── main.tf               # IBM Cloud resources: IAM, COS, Secrets Manager, KMS
├── provider.tf           # IBM Cloud provider configuration
├── variables.tf          # Variable definitions
├── versions.tf           # Provider and Terraform versions
├── outputs.tf            # Provides Terraform outputs (HMAC, Access Group IDs) to Ansible ( OPTIONAL or can be definedin main.tf)
└── ansible/
    ├── hosts.inv         # Ansible inventory file
    ├── wxd_create.yaml   # Creates Watsonx.data catalog and sets up permissions
    └── wxd_destroy.yaml  # Cleans up WXD catalog and related resources
```
## Prerequisites

Ensure the following before using this automation:

- IBM Cloud account with access to required services
- IBM Schematics workspace configured with this repo
- Terraform v1.4+ (managed by Schematics)
- Permissions to manage:
  - IAM access groups and policies
  - COS, KMS, Secrets Manager
  - Watsonx.data (catalog, schema, engine)


#How to Use
🔹 Step 1: Clone the Repository 
git clone https://github.com/resprath/Automations
cd Automations
🔹 Step 2: Create a Schematics Workspace
Go to IBM Cloud Schematics.
Create a new workspace.
Set GitHub as the source control and link this repo.
Set input variables via UI or variables.tf
🔹 Step 3: Configure Variables
Edit terraform.tfvars or define variables in the UI such as 
region            = "us-south"
catalog_name      = "demo-catalog"
catalog_type      = "iceberg"
description       = "Analytics catalog for demo"
bucket_display    = "demo-bucket"
bucket_type       = "primary"
🔹 Step 4: Apply Plan
Run Apply Plan in the Schematics UI after ensuring the following variable in Schematics UI is set to true : -var="create=true".
This will Provision all required cloud services and Watsonx.data resources
🔹 Step 5: Destroy resources
In Schematics, Run Apply plan after changing -var="create=false " which will delete all WXD resources and then click Destroy to remove all Terraform-managed resources
