##############################################################################
# Create ACL Rules For Zone
##############################################################################

locals {
    allow_rules = flatten([
        for cidr in local.control_plane_ips[var.region]:
        [
            { 
                name        = "allow-inbound-control-pane-${index(local.control_plane_ips[var.region], cidr) + 1}"
                action      = "allow"
                direction   = "inbound"
                destination = "0.0.0.0/0"
                source      = cidr
                tcp         = null
                udp         = null
                icmp        = null
            },
            # {
            #     name        = "allow-outbound-control-pane-${index(local.control_plane_ips[var.region], cidr) + 1}"
            #     action      = "allow"
            #     direction   = "outbound"
            #     destination = cidr
            #     source      = "0.0.0.0/0"
            #     tcp         = null
            #     udp         = null
            #     icmp        = null
            # }
        ]
    ])
}

##############################################################################


##############################################################################
# Output ACL Rules
##############################################################################

output rules {
    description = "List of rules for control plane IP for a region"
    value       = local.allow_rules
}

##############################################################################