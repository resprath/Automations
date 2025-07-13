############################### Reader Access Group #########################################
resource "ibm_iam_access_group" "accgroup_reader" {
  name        = var.access_group_name[0]
  description = "Access group created for reader via IBM Cloud Schematics"
}
resource "ibm_iam_service_id" "serviceID_reader" {
  name = var.service_id[0]
}
resource "ibm_iam_access_group_members" "accgroupmem_reader" {
  access_group_id = ibm_iam_access_group.accgroup_reader.id
  iam_service_ids = [ibm_iam_service_id.serviceID_reader.id]
}
############################### Auto Access Group ###########################################
resource "ibm_iam_access_group" "accgroup_auto" {
  name        = var.access_group_name[1]
  description = "Access group created for automation via IBM Cloud Schematics.NON-REQUESTABLE"
}
resource "ibm_iam_service_id" "serviceID_auto" {
  name = var.service_id[1]
}
resource "ibm_iam_access_group_members" "accgroupmem_auto" {
  access_group_id = ibm_iam_access_group.accgroup_auto.id
  iam_service_ids = [ibm_iam_service_id.serviceID_auto.id]
}
############################################################################################
data "ibm_resource_group" "cos_group" {
  name = var.cos_group
}
data "ibm_resource_instance" "kms_instance_dal" {
  name = var.kms_instance_dal
}
data "ibm_resource_instance" "kms_instance_wdc" {
  name = var.kms_instance_wdc
}
data "ibm_resource_instance" "secrets_manager_instance" {
  name    = var.secrets_manager_instance
  service = "secrets-manager"
}
################################ COS Instance ##############################################
resource "ibm_resource_instance" "cos_instance" {
  name              = var.cos_instance[0]
  resource_group_id = data.ibm_resource_group.cos_group.id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}
############################### COS Replica Instance ######################################
resource "ibm_resource_instance" "cos_replica_instance" {
  name              = var.cos_instance[1]
  resource_group_id = data.ibm_resource_group.cos_group.id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}
############################## Encryption key for Source Bucket ##########################
resource "ibm_kms_key" "kms_key_dal" {
  instance_id  = data.ibm_resource_instance.kms_instance_dal.guid
  key_name     = var.kms_key_dal
  standard_key = false
  force_delete =true
}
############################### Encryption key for Replica Bucket ########################
resource "ibm_kms_key" "kms_key_wdc" {
  instance_id  = data.ibm_resource_instance.kms_instance_wdc.guid
  key_name     = var.kms_key_wdc
  standard_key = false
  force_delete =true
}
#################################### Source Bucket ########################################
resource "ibm_cos_bucket" "bucket_name" {
  bucket_name          = var.bucket_name[0]
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = var.ibm_region_dal
  storage_class        = "smart"
  kms_key_crn         = ibm_kms_key.kms_key_dal.id
  activity_tracking {
    read_data_events     = true
    write_data_events    = true
    management_events    = true
  }
  metrics_monitoring {
    usage_metrics_enabled  = true
    request_metrics_enabled = true
  }
}
#################################### Replica Bucket ########################################
resource "ibm_cos_bucket" "bucket_replica_name" {
  bucket_name          = var.bucket_name[1]
  resource_instance_id = ibm_resource_instance.cos_replica_instance.id
  region_location      = var.ibm_region_wdc
  storage_class        = "smart"
  kms_key_crn         = ibm_kms_key.kms_key_wdc.id
  activity_tracking {
    read_data_events     = true
    write_data_events    = true
    management_events    = true
  }
  metrics_monitoring {
    usage_metrics_enabled  = true
    request_metrics_enabled = true
  }
}
########################## Reader Access Group permission for WXD ##############################
resource "ibm_iam_access_group_policy" "policy_wxd_reader" {
  roles           = ["DataAccess", "Viewer", "MetastoreAdmin", "MetastoreViewer", "Operator"]
  access_group_id = ibm_iam_access_group.accgroup_reader.id
  resources {
    service           = "lakehouse"
    resource_group_id = data.ibm_resource_group.cos_group.id
  }
}
########################## Reader Access Group permission for COS ##############################
resource "ibm_iam_access_group_policy" "policy_cos_reader" {
  roles           = ["Reader", "Viewer", "Content Reader", "Object Reader"]
  access_group_id = ibm_iam_access_group.accgroup_reader.id
  resources {
    service           = "cloud-object-storage"
    resource_instance_id = element(split(":", ibm_resource_instance.cos_instance.id), 7)
  }
}
######################### Reader Access Group permission for Resource Group ##############################
resource "ibm_iam_access_group_policy" "policy_rg_reader" {
  roles           = ["Viewer"]
  access_group_id = ibm_iam_access_group.accgroup_reader.id
  resources {
    resource_type     = "resource-group"
    resource_group_id = data.ibm_resource_group.cos_group.id
  }
}
########################## Auto Access Group permission for WXD ##############################
resource "ibm_iam_access_group_policy" "policy_wxd_auto" {
  roles           = ["DataAccess", "Viewer", "Editor", "MetastoreAdmin", "MetastoreViewer", "Operator"]
  access_group_id = ibm_iam_access_group.accgroup_auto.id
  resources {
    service           = "lakehouse"
    resource_group_id = data.ibm_resource_group.cos_group.id
  }
}
########################## Auto Access Group permission for COS ##############################
resource "ibm_iam_access_group_policy" "policy_cos_auto" {
  roles           = ["Reader", "Writer", "Viewer", "Content Reader", "Object Reader", "Object Writer"]
  access_group_id = ibm_iam_access_group.accgroup_auto.id
  resources {
    service           = "cloud-object-storage"
    resource_instance_id = element(split(":", ibm_resource_instance.cos_instance.id), 7)
  }
}
######################### Auto Access Group permission for Resource Group ##############################
resource "ibm_iam_access_group_policy" "policy_rg_auto" {
  roles           = ["Viewer"]
  access_group_id = ibm_iam_access_group.accgroup_auto.id
  resources {
    resource_type     = "resource-group"
    resource_group_id = data.ibm_resource_group.cos_group.id
  }
}
########################## Create authorization policy for COS #########################################
resource "ibm_iam_authorization_policy" "sm_policy_cos" {
  source_service_name         = "secrets-manager"
  source_resource_instance_id = data.ibm_resource_instance.secrets_manager_instance.guid
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = ibm_resource_instance.cos_instance.guid
  roles                       = ["Key Manager"]
}
######################## Create authorization policy for COS replica ###############################

resource "ibm_iam_authorization_policy" "sm_policy_cos_replica" {
  source_service_name         = "secrets-manager"
  source_resource_instance_id = data.ibm_resource_instance.secrets_manager_instance.guid
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = ibm_resource_instance.cos_replica_instance.guid
  roles                       = ["Key Manager"]
}
####################### Create a secret group for reader in the Secrets Manager ###############################
resource "ibm_sm_secret_group" "sm_secret_group_reader" {
  depends_on  = [ibm_iam_authorization_policy.sm_policy_cos,ibm_iam_authorization_policy.sm_policy_cos_replica]
  instance_id = data.ibm_resource_instance.secrets_manager_instance.guid
  region      = var.ibm_region_dal
  name        = var.sm_group_name[0]
  description = "Secret manager group created for reader via IBM Cloud Schematics"
}
####################### Create a secret group for auto in the Secrets Manager ################################
resource "ibm_sm_secret_group" "sm_secret_group_auto" {
  depends_on  = [ibm_iam_authorization_policy.sm_policy_cos,ibm_iam_authorization_policy.sm_policy_cos_replica]
  instance_id = data.ibm_resource_instance.secrets_manager_instance.guid
  region      = var.ibm_region_dal
  name        = var.sm_group_name[1]
  description = "Secret manager group created for automation via IBM Cloud Schematics"
}
###################### Create IAM API Key secret (Reader) in the Secrets Manager #####################################

resource "ibm_sm_iam_credentials_secret" "sm_iam_credentials_secret_reader" {
  depends_on  = [ibm_iam_authorization_policy.sm_policy_cos,ibm_iam_authorization_policy.sm_policy_cos_replica]
  instance_id = data.ibm_resource_instance.secrets_manager_instance.guid
  region      = var.ibm_region_dal
  name        = var.iam_secret_name[0]
  description = "IAM service ID mapped for this secret."
  labels      = ["access-group-api"]
  rotation {
    auto_rotate = false
    interval    = 1
    unit        = "day"
  }
  secret_group_id = ibm_sm_secret_group.sm_secret_group_reader.secret_group_id
  service_id      = ibm_iam_service_id.serviceID_reader.id
  ttl             = "7776000"
}
###################### Create Service credentials for COS instance (Reader)in the Secrets Manager #######################

resource "ibm_sm_service_credentials_secret" "sm_service_credentials_secret_cos_reader" {
  depends_on  = [ibm_iam_authorization_policy.sm_policy_cos,ibm_iam_authorization_policy.sm_policy_cos_replica]
  instance_id = data.ibm_resource_instance.secrets_manager_instance.guid
  region      = var.ibm_region_dal
  name        = var.cos_service_creds_secret_name[0]
  description = "Service credentials secret for COS instance."
  labels      = ["cos-service-creds"]
  rotation {
    auto_rotate = true
    interval    = 1
    unit        = "day"
  }
  secret_group_id = ibm_sm_secret_group.sm_secret_group_reader.secret_group_id
  source_service {
    instance {
      crn = ibm_resource_instance.cos_instance.crn
    }
    role {
      crn = "crn:v1:bluemix:public:iam::::serviceRole:Reader"
    }
    parameters = { "HMAC" : true, "serviceid_crn" : ibm_iam_service_id.serviceID_reader.crn }
  }
}
####################### Create Service credentials for COS instance replica (Reader) in the Secrets Manager ######################

resource "ibm_sm_service_credentials_secret" "sm_service_credentials_secret_cos_replica_reader" {
  depends_on  = [ibm_iam_authorization_policy.sm_policy_cos,ibm_iam_authorization_policy.sm_policy_cos_replica]
  instance_id = data.ibm_resource_instance.secrets_manager_instance.guid
  region      = var.ibm_region_dal
  name        = var.cos_service_creds_secret_name_replica[0]
  description = "Service credentials secret for COS instance replica."
  labels      = ["cos-service-creds"]
  rotation {
    auto_rotate = true
    interval    = 1
    unit        = "day"
  }
  secret_group_id = ibm_sm_secret_group.sm_secret_group_reader.secret_group_id
  source_service {
    instance {
      crn = ibm_resource_instance.cos_replica_instance.crn
    }
    role {
      crn = "crn:v1:bluemix:public:iam::::serviceRole:Reader"
    }
    parameters = { "HMAC" : true, "serviceid_crn" : ibm_iam_service_id.serviceID_reader.crn }
  }
}
################# Create IAM API Key secret (Auto) in the Secrets Manager ########################
resource "ibm_sm_iam_credentials_secret" "sm_iam_credentials_secret_auto" {
  depends_on  = [ibm_iam_authorization_policy.sm_policy_cos,ibm_iam_authorization_policy.sm_policy_cos_replica]
  instance_id = data.ibm_resource_instance.secrets_manager_instance.guid
  region      = var.ibm_region_dal
  name        = var.iam_secret_name[1]
  description = "IAM service ID mapped for this secret."
  labels      = ["access-group-api"]
  rotation {
    auto_rotate = false
    interval    = 1
    unit        = "day"
  }
  secret_group_id = ibm_sm_secret_group.sm_secret_group_auto.secret_group_id
  service_id      = ibm_iam_service_id.serviceID_auto.id
  ttl             = "7776000"
}
################ Create Service credentials for COS instance (Auto) in the Secrets Manager ###################
resource "ibm_sm_service_credentials_secret" "sm_service_credentials_secret_cos_auto" {
  depends_on  = [ibm_iam_authorization_policy.sm_policy_cos,ibm_iam_authorization_policy.sm_policy_cos_replica]
  instance_id = data.ibm_resource_instance.secrets_manager_instance.guid
  region      = var.ibm_region_dal
  name        = var.cos_service_creds_secret_name[1]
  description = "Service credentials secret for COS instance."
  labels      = ["cos-service-creds"]
  rotation {
    auto_rotate = true
    interval    = 1
    unit        = "day"
  }
  secret_group_id = ibm_sm_secret_group.sm_secret_group_auto.secret_group_id
  source_service {
    instance {
      crn = ibm_resource_instance.cos_instance.crn
    }
    role {
      crn = "crn:v1:bluemix:public:iam::::serviceRole:Writer"
    }
    parameters = { "HMAC" : true, "serviceid_crn" : ibm_iam_service_id.serviceID_auto.crn }
  }
}
############### Create Service credentials for COS instance replica (Auto) in the Secrets Manager ###################
resource "ibm_sm_service_credentials_secret" "sm_service_credentials_secret_cos_replica_auto" {
  depends_on  = [ibm_iam_authorization_policy.sm_policy_cos,ibm_iam_authorization_policy.sm_policy_cos_replica]
  instance_id = data.ibm_resource_instance.secrets_manager_instance.guid
  region      = var.ibm_region_dal
  name        = var.cos_service_creds_secret_name_replica[1]
  description = "Service credentials secret for COS instance replica."
  labels      = ["cos-service-creds"]
  rotation {
    auto_rotate = true
    interval    = 1
    unit        = "day"
  }
  secret_group_id = ibm_sm_secret_group.sm_secret_group_auto.secret_group_id
  source_service {
    instance {
      crn = ibm_resource_instance.cos_replica_instance.crn
    }
    role {
      crn = "crn:v1:bluemix:public:iam::::serviceRole:Writer"
    }
    parameters = { "HMAC" : true, "serviceid_crn" : ibm_iam_service_id.serviceID_auto.crn }
  }
}
################ HMAC secret of source COS instance (Used for WXD catalog connection)##################
resource "ibm_resource_key" "cos_instance_reader_hmac" {
  name                 = var.cos_instance_hmac[0]
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  parameters           = { HMAC = true }
}
############### HMAC secret of replica COS instance (Used for WXD catalog connection) ##################
resource "ibm_resource_key" "cos_instance_replica_reader_hmac" {
  name                 = var.cos_instance_hmac[1]
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.cos_replica_instance.id
  parameters           = { HMAC = true }
}
########### Policy for catalog_reader access group to view catalog secrets #################
resource "ibm_iam_access_group_policy" "sm_policy_reader_view" {
  roles           = ["Viewer"]
  access_group_id = ibm_iam_access_group.accgroup_reader.id
  resources {
    service           = "secrets-manager"
    resource_instance_id = element(split(":", data.ibm_resource_instance.secrets_manager_instance.id), 7)
  }
}
########### Policy for catalog_reader access group to read catalog secrets #################
resource "ibm_iam_access_group_policy" "sm_policy_reader_key" {
  roles           = ["Reader", "SecretsReader"]
  access_group_id = ibm_iam_access_group.accgroup_reader.id
  resources {
    service           = "secrets-manager"
    resource_instance_id = element(split(":", data.ibm_resource_instance.secrets_manager_instance.id), 7)
    resource_type = "secret-group"
    resource      = ibm_sm_secret_group.sm_secret_group_reader.secret_group_id
  }
}
########### Policy for catalog_auto access group to view catalog_auto secrets ################
resource "ibm_iam_access_group_policy" "sm_policy_auto_view" {
  roles           = ["Viewer"]
  access_group_id = ibm_iam_access_group.accgroup_auto.id
  resources {
    service           = "secrets-manager"
    resource_instance_id = element(split(":", data.ibm_resource_instance.secrets_manager_instance.id), 7)
  }
}
########### Policy for catalog_auto access group to read catalog_auto secrets ################
resource "ibm_iam_access_group_policy" "sm_policy_auto_key" {
  roles           = ["Reader", "SecretsReader"]
  access_group_id = ibm_iam_access_group.accgroup_auto.id
  resources {
    service           = "secrets-manager"
    resource_instance_id = element(split(":", data.ibm_resource_instance.secrets_manager_instance.id), 7)
    resource_type = "secret-group"
    resource      = ibm_sm_secret_group.sm_secret_group_auto.secret_group_id
  }
}
####Output of HMAC for WXD###
output "cos_instance_reader_hmac" {
  value = ibm_resource_key.cos_instance_reader_hmac.name
}

###Output of Accessgroups and HMAC to input to WXD automation###

output "reader_access_group_id" {
  value = ibm_iam_access_group.accgroup_reader.id
}

output "auto_access_group_id" {
  value = ibm_iam_access_group.accgroup_auto.id
}

output "hmac_credentials_json" {
  value = ibm_resource_key.cos_instance_reader_hmac.credentials_json
  sensitive = true
}

output "hmac_credentials" {
  value = ibm_resource_key.cos_instance_reader_hmac.credentials
  sensitive = true
}

# ################ Ansible playbook for WXD operations - 35 ##################
resource "ansible_playbook" "create_playbook" {
  count = var.create ? 1 : 0
  playbook   = var.create_playbook
  name       = "localhost"
  verbosity  = 6
  replayable = true
  extra_vars = {
    iam_url = var.iam_url
    ibmcloud_api_key = var.ibmcloud_api_key
    auth_instance_id = var.auth_instance_id
    bucket_registration_api = var.bucket_registration_api
    bucket_endpoint = var.bucket_endpoint
    managed_by = var.managed_by
    hmac_credentials = jsonencode(resource.ibm_resource_key.cos_instance_reader_hmac.credentials)
    catalog_name = var.catalog_name
    catalog_type = var.catalog_type
    ansible_bucket_name = ibm_cos_bucket.bucket_name.bucket_name
    region = ibm_cos_bucket.bucket_name.region_location
    description = var.description
    cos_instance_name = ibm_resource_instance.cos_instance.name
    bucket_display = var.bucket_display
    bucket_type = var.bucket_type
    presto_engine_url = var.presto_engine_url
    engine_id = var.engine_id
    spark_id = var.spark_id
    reader_access_group_id = ibm_iam_access_group.accgroup_reader.id
    auto_access_group_id = ibm_iam_access_group.accgroup_auto.id
    admin1_access_group_id = var.admin1_access_group_id
    admin2_access_group_id = var.admin2_access_group_id
    admin3_access_group_id = var.admin3_access_group_id
    catalog_url = var.catalog_url
    storage_url = var.storage_url
    spark_url = var.spark_url
    reader_catalog_group_permission = var.reader_catalog_group_permission
    reader_engine_group_permission = var.reader_engine_group_permission
    reader_storage_group_permission = var.reader_storage_group_permission
    auto_catalog_group_permission = var.auto_catalog_group_permission
    auto_engine_group_permission = var.auto_engine_group_permission
    auto_storage_group_permission = var.auto_storage_group_permission
    admin_storage_group_permission = var.admin_storage_group_permission
  }
}
resource "ansible_playbook" "destroy_playbook" {
  count = var.destroy ? 1 : 0
  playbook   = var.destroy_playbook
  name       = "localhost"
  verbosity  = 6
  replayable = true
  extra_vars = {
    iam_url = var.iam_url
    ibmcloud_api_key = var.ibmcloud_api_key
    auth_instance_id = var.auth_instance_id
    bucket_registration_api = var.bucket_registration_api
    bucket_endpoint = var.bucket_endpoint
    managed_by = var.managed_by
    hmac_credentials = jsonencode(resource.ibm_resource_key.cos_instance_reader_hmac.credentials)
    catalog_name = var.catalog_name
    catalog_type = var.catalog_type
    ansible_bucket_name = ibm_cos_bucket.bucket_name.bucket_name
    region = ibm_cos_bucket.bucket_name.region_location
    description = var.description
    cos_instance_name = ibm_resource_instance.cos_instance.name
    bucket_display = var.bucket_display
    bucket_type = var.bucket_type
    presto_engine_url = var.presto_engine_url
    engine_id = var.engine_id
    spark_id = var.spark_id
    reader_access_group_id = ibm_iam_access_group.accgroup_reader.id
    auto_access_group_id = ibm_iam_access_group.accgroup_auto.id
    catalog_url = var.catalog_url
    storage_url = var.storage_url
    spark_url = var.spark_url
  }
}