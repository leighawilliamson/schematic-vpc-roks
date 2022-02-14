##############################################################################
# IBM Cloud Provider
##############################################################################

provider ibm {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.region
  ibmcloud_timeout      = 60
}

##############################################################################


##############################################################################
# Resource Group where VPC Resources Will Be Created
##############################################################################

data ibm_resource_group resource_group {
  name = var.resource_group
}

##############################################################################


##############################################################################
# Create VPC
##############################################################################

module multizone_vpc {
  source               = "./multizone-vpc"
  prefix               = var.prefix
  region               = var.region
  resource_group_id    = data.ibm_resource_group.resource_group.id
  classic_access       = var.classic_access
  subnets              = var.subnets
  use_public_gateways  = var.use_public_gateways
  acl_rules            = local.all_acl_rules
  security_group_rules = var.security_group_rules
}

##############################################################################


##############################################################################
# Access Groups
##############################################################################

module access_groups {
  source        = "./iam"
  access_groups = var.access_groups

  depends_on = [ data.ibm_resource_group.resource_group ]
}

##############################################################################


##############################################################################
# COS Instance
##############################################################################

resource ibm_resource_instance cos {
  name              = "${var.prefix}-cos"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = data.ibm_resource_group.resource_group.id

  parameters = {
    service-endpoints = "private"
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }

}

##############################################################################


##############################################################################
# Create ROKS Cluster
##############################################################################

data external default_openshift_version {
  count   = var.kube_version == "default" ? 1 : 0
  program = [
    "bash",
    "${path.module}/default_kube_version.sh"
  ]

  query = {
    API_KEY   = var.ibmcloud_api_key
  }
}

module roks_cluster {
  source            = "./cluster"
  # Account Variables
  prefix            = var.prefix
  region            = var.region
  resource_group_id = data.ibm_resource_group.resource_group.id
  # VPC Variables
  vpc_id            = module.multizone_vpc.vpc_id
  subnets           = module.multizone_vpc.subnet_zone_list
  # Cluster Variables
  machine_type      = var.machine_type
  workers_per_zone  = var.workers_per_zone
  entitlement       = var.entitlement
  # If default, use bash to recieve latest version via API.
  kube_version      = var.kube_version == "default" ? data.external.default_openshift_version[0].result.default_version : var.kube_version
  tags              = var.tags
  worker_pools      = var.worker_pools
  cos_id            = ibm_resource_instance.cos.id
}

##############################################################################
