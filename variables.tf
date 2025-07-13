##############################################################################
# Account Variables
##############################################################################
variable ibm_region {
    description = "IBM Cloud region where all resources will be deployed"
    type        = string
    default     = ""
}
variable ibm_region_dal {
    description = "IBM Cloud region where all resources will be deployed"
    type        = string
    default     = ""
}
variable ibm_region_wdc {
    description = "IBM Cloud region where all resources will be deployed"
    type        = string
    default     = ""
}
variable resource_group_id {
    description = "ID of the IBM Cloud Resource Group where KMS and COS are deployed "
    type        = string
    default     = ""
}
variable cos_group {
    description = "Name for IBM Cloud Resource Group where KMS and COS are deployed "
    type        = string
    default     = ""
}
variable secrets_manager_instance {
  description = "This is the secrets manager instance for keeping the cloud secrets"
  type        = string
  default     = ""
}
###############################################################################
## Access Group Variables
###############################################################################

variable access_group_name {
    description = "Comma separated Access group names"
    type        = list
    default     = ["",""]
}
variable service_id {
    description = "Comma separated Service ID names"
    type        = list
    default     = ["",""]
}
###############################################################################
## COS Variables
###############################################################################
variable cos_instance {
    description = "Name for COS at global level"
    type        = list
    default     = ["",""]
}
variable bucket_name {
    description = "Name for the buckets"
    type        = list
    default     = ["",""]
}
variable cos_instance_hmac {
    description = "Name for HMAC credential at COS level"
    type        = list
    default     = ["", ""]
}
###############################################################################
### Key Protect Variables
###############################################################################
variable kms_instance_dal {
    description = "Name for keyprotect instance in DAL"
    type        = string
    default     = ""
}
variable kms_instance_wdc {
    description = "Name for keyprotect instance in WDC"
    type        = string
    default     = ""
}
variable kms_key_dal {
    description = "Name for root encryption key in DAL"
    type        = string
    default     = ""
}
variable kms_key_wdc {
    description = "Name for root encryption key in WDC"
    type        = string
    default     = ""
}
#################################################################################
### Secret Manager Variables
################################################################################
variable "sm_group_name" {
  description = "Secret manager group"
  type        = list
  default     = ["", ""]
}
variable "iam_secret_name" {
  description = "IAM secret name in secret manager"
  type        = list
  default     = ["", ""]
}
variable "cos_service_creds_secret_name" {
  description = "Secret name for the COS service credentials"
  type        = list
  default     = ["", ""]
}
variable "cos_service_creds_secret_name_replica" {
  description = "Secret name for the COS replica service credentials"
  type        = list
  default     = ["", ""]
}
#################################################################################
### Ansible Variables
#################################################################################
variable "iam_url" {
  description = "IAM URL "
  type        = string
  default     = ""
}
variable "create_playbook" {
  description = "Ansible create play book path "
  type        = string
  default     = "ansible/wxd_create.yaml"
}
variable "destroy_playbook" {
  description = "Ansible destroy play book path "
  type        = string
  default     = "ansible/wxd_destroy.yaml"
}
variable "auth_instance_id" {
  description = "Auth instance id "
  type        = string
  default     = ""
}
variable "bucket_registration_api" {
  description = "Bucket Registration API "
  type        = string
  default     = ""
}
variable "bucket_endpoint" {
  description = "Bucket End Point "
  type        = string
  default     = ""
}
variable "managed_by" {
  description = "Type "
  type        = string
  default     = ""
}
variable "catalog_name" {
  description = "Name of Catalog "
  type        = string
  default     = "demo_catalog"
}
variable "catalog_type" {
  description = "Type of Catalog "
  type        = string
  default     = "iceberg"
}
variable "description" {
  description = "Catalog description "
  type        = string
  default     = ""
}
variable "bucket_display" {
  description = "Display name of Bucket "
  type        = string
  default     = "demo_catalog"
}
variable "bucket_type" {
  description = "Type of Bucket "
  type        = string
  default     = "ibm_cos"
}
variable "engine_id" {
  description = "Presto Engine ID "
  type        = string
  default     = ""
}
variable "spark_id" {
  description = "Spark Engine ID"
  type        = string
  default     = ""
}
variable "presto_engine_url" {
  description = "Presto engine URL"
  type        = string
  default     = ""
}
variable "catalog_url" {
  description = "Catalog URL "
  type        = string
  default     = ""
}
variable "storage_url" {
  description = "COS Storage URL "
  type        = string
  default     = ""
}
variable "spark_url" {
  description = "Spark Engine URL "
  type        = string
  default     = ""
}
variable "admin1_access_group_id" {
  description = "Primary Admin Group "
  type        = string
  default     = ""
}
variable "admin2_access_group_id" {
  description = "Secondary Admin Group "
  type        = string
  default     = ""
}
variable "admin3_access_group_id" {
  description = "Secondary Admin Group "
  type        = string
  default     = ""
}
variable "reader_catalog_group_permission" {
  description = "Reader Permission on Catalog "
  type        = string
  default     = ""
}
variable "reader_engine_group_permission" {
  description = "Reader Permission on Engine "
  type        = string
  default     = ""
}
variable "reader_storage_group_permission" {
  description = "Reader Permission on COS "
  type        = string
  default     = ""
}
variable "auto_catalog_group_permission" {
  description = "Writer Permission on Catalog "
  type        = string
  default     = ""
}
variable "auto_engine_group_permission" {
  description = "Writer Permission on Engine "
  type        = string
  default     = ""
}
variable "auto_storage_group_permission" {
  description = "Writer Permission on COS "
  type        = string
  default     = ""
}
variable "admin_storage_group_permission" {
  description = "Writer Permission on COS "
  type        = string
  default     = ""
}
variable "create" {
  description = "Flag to determine whether to run create_playbook"
  type        = bool
  default     = true
}
variable "destroy" {
  description = "Flag to determine whether to run destroy_playbook"
  type        = bool
  default     = false
}