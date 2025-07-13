terraform {
required_version = ">=1.0.0, <2.0"
required_providers {
    ibm = {
    source = "ibm-cloud/ibm"
    version = "1.77.1"
    }
    ansible = {
      version = "~> 1.3.0"
      source  = "ansible/ansible"
    }
 }
}
