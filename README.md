# Readme

HOW TO RUN THIS TERRAFORM CODE (NOT ON SCHEMATICS)

In `main.tf`, the first 34 resources are related to IBM cloud resources such as secrets, COS instances, buckets, KMS instance, secrets etc.

Along with the regular Cloud variables ( 34 resources) we have Two Ansible playbooks defined as resources. One is for creating WXD resources and another one for deleting.

Create is a two step with plan and apply.
NOTE : -auto-approve will run the script without waiting for the approval in terms of yes/no.. Be vigilant about what you are about to run.

1) terraform plan  

2) terraform apply -var="create=true" -auto-approve  



Destroy is a 2 step process:

1) terraform apply -target="ansible_playbook.destroy_playbook" -var="destroy=true"  -auto-approve


2) terraform destroy -auto-approve

Destroy is two step since we are defining ansible playbook as a resource in terraform. Since its not a native resource of terraform like the COS variables, we should pass it as a parameter to apply in the terraform. Then we can run the regular destroy for the Cloud variables.

-var option works in the below way:

In variables.tf we specify 2 variables

variable "create" {
  description = "Flag to determine whether to run create_playbook"
  type        = bool
  default     = false
}
variable "destroy" {
  description = "Flag to determine whether to run destroy_playbook"
  type        = bool
  default     = false
}

We define them in main.tf as resources
 resource "ansible_playbook" "create_playbook" {} and resource "ansible_playbook" "destroy_playbook" {} 

 Actual path of the playbooks are defined in variables.tf
 variable "create_playbook" {
  description = "Ansible create play book path "
  type        = string
  default     = "ansible/wxd_create.yaml"
}
variable "destroy_playbook" {
  description = "Ansible destroy play book path "
  type        = string
  default     = "ansible/wxd_destroy.yaml"

Define ansible block with right version in versions.tf

## Dependencies

1. JQ is a dependency  : `terraform output -json hmac_credentials| jq '."cos_hmac_keys.access_key_id"'`
hmac_credentials = jsonencode(resource.ibm_resource_key.cos_instance_reader_hmac.credentials)

2. In main.tf , define extra_vars by passing variables.  eg : catalog_name = var.catalog_name

Some of the variables are obtained as an output of terraform code. 
Eg :
hmac_credentials = jsonencode(resource.ibm_resource_key.cos_instance_reader_hmac.credentials)
access_group_id = ibm_iam_access_group.accgroup_reader.id

Some are already defined in main, use terraform console, parse and find it 

Eg :
region = ibm_cos_bucket.bucket_name.region_location
cos_instance_name = ibm_resource_instance.cos_instance.name

3. Make sure all ansible variables are defined in terraform_tfvars and referenced in variables.tf and main.tf


4. terraform plan  will run 35 terraform resource, ie , 34 Cloud resources+ 1 ansible playbook for WXD. 
5. In the playbook , we are passing data so the code looks compact.

eg : register_bucket_data: > This will pass all the fields in the actual curl like

 curl -X POST -H "accept: application/json" -H "AuthInstanceId: {{ auth_instance_id }}" -H "Authorization: Bearer {{ access_token }}" -H "Content-Type: application/json" -d '{
          "bucket_details": {
            "access_key": "{{ item.access_key }}",
            "bucket_name": "{{ ansible_bucket_name }}",
            "endpoint": "{{ endpoint }}",
            "secret_key": "{{ item.secret_key }}"
          },
          "bucket_display_name": "{{ item.bucket_display }}",
          "bucket_type": "{{ item.bucket_type }}",
          "description": "{{ item.description }}",
          "managed_by": "{{ managed_by }}",
          "region": "{{ region }}",
          "associated_catalog": {
            "catalog_name": "{{ item.catalog_name }}",
            "catalog_type": "{{ item.catalog_type }}"
          }
        }' "{{ bucket_url }}"

        The above -d block can be passed as below :


     register_bucket_data:
       bucket_details:
            access_key: "{{ access_key_id }}"
            bucket_name: "{{ ansible_bucket_name }}"
            endpoint: "{{ bucket_endpoint }}"
            secret_key: "{{ secret_access_key }}"
          bucket_display_name: "{{ bucket_display }}"
          bucket_type: "{{ bucket_type }}"
          description: "{{ description }}"
          managed_by: "{{ managed_by }}"
          region: "{{ region }}"
          associated_catalog:
            catalog_name: "{{ catalog_name }}"
            catalog_type: "{{ catalog_type }}"

So the actual command shortens to
        curl -X POST {{ api_header }} \
        -d '{{ register_bucket_data | to_nice_json }}' \
        "{{ bucket_registration_api }}"

   -d '{{ register_bucket_data | to_nice_json }}'  > This converts the data in bucket_details above to a formatted json as expected in the curl input.



DEBUGGING : 

Inside ansible folder a file gets created where output of ansible playook  is being written
file_generated_by_terraform_and_ansible.json

$ cat ansible/file_generated_by_terraform_and_ansible.json

This will log all o/ps.

Also use terraform console to debug

whatever variables /resources in main.tf can be displayed in terraform console

example:
$ terraform console
> var.bucket_registration_api
"https://us-south.lakehouse.cloud.ibm.com/lakehouse/api/v2/bucket_registrations"
> ibm_cos_bucket.bucket_name.bucket_name
"demo1-catalog-test"
>  

This way you determine that the variable in main.tf is right.

terraform show|grep ^resource > Show all resources in a compact way
