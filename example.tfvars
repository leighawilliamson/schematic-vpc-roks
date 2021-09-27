ibmcloud_api_key=""
TF_VERSION="1.0"
prefix="gcat-multizone"
region="us-south"
resource_group="gcat-landing-zone-dev"
access_groups=[ { name = "admin" description = "An example admin group" policies = [ { name = "admin_all" resources = { resource_group = "gcat-landing-zone-dev" } roles = ["Administrator","Manager"] } ] dynamic_policies = [] invite_users = [ "test@test.test" ] }, { name = "dev" description = "A developer access group" policies = [ { name = "dev_view_vpc" resources = { resource_group = "gcat-landing-zone-dev" service = "id" } roles = ["Viewer"] } ] invite_users = ["test@test.test"] } ]
classic_access=false
subnets={ zone-1 = [ { name = "subnet-a" cidr = "10.10.10.0/24" public_gateway = true } ], zone-2 = [ { name = "subnet-b" cidr = "10.20.10.0/24" public_gateway = true } ], zone-3 = [ { name = "subnet-c" cidr = "10.30.10.0/24" public_gateway = true } ] }
use_public_gateways={ zone-1 = true zone-2 = true zone-3 = true }
acl_rules=[ { name = "allow-all-inbound" action = "deny" direction = "inbound" destination = "0.0.0.0/0" source = "0.0.0.0/0" }, { name = "allow-all-outbound" action = "deny" direction = "outbound" destination = "0.0.0.0/0" source = "0.0.0.0/0" } ]
security_group_rules=[ { name = "allow-inbound-ping" direction = "inbound" remote = "0.0.0.0/0" icmp = { type = 8 } }, { name = "allow-inbound-ssh" direction = "inbound" remote = "0.0.0.0/0" tcp = { port_min = 22 port_max = 22 } }, ]
machine_type="bx2.4x16"
workers_per_zone=2
entitlement="cloud_pak"
kube_version="4.7.23_openshift"
wait_till="IngressReady"
tags=[]
worker_pools=[ { name = "dev" machine_type = "cx2.8x16" workers_per_zone = 2 }, { name = "test" machine_type = "mx2.4x32" workers_per_zone = 2 } ]
