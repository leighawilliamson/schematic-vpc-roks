##############################################################################
# Create Subnet ACL Rules
##############################################################################

locals {
    # Allow inbound and outbound traffic from each subnet
    subnet_allow_rules = flatten([
        # For each zone in subnets
        for zone in keys(var.subnets):
        [
            # For each subnet in that zone, create an allow inbound and allow outbound rule
            for subnet in var.subnets[zone]:
            [
                { 
                    name        = "allow-inbound-${var.prefix}-${subnet.name}"
                    action      = "allow"
                    direction   = "inbound"
                    destination = "0.0.0.0/0"
                    source      = subnet.cidr
                    tcp         = null
                    udp         = null
                    icmp        = null
                },
                {
                    name        = "allow-outbound-${var.prefix}-${subnet.name}"
                    action      = "allow"
                    direction   = "outbound"
                    destination = subnet.cidr
                    source      = "0.0.0.0/0"
                    tcp         = null
                    udp         = null
                    icmp        = null
                }
            ]
        ]
    ])

    # Create rules to allow clusters to work
    cluster_allow_rules = [
        # Cluster Rules
        {
            name        = "roks-create-worker-nodes-inbound"
            action      = "allow"
            source      = "161.26.0.0/16"
            destination = "0.0.0.0/0"
            direction   = "inbound"
        },
        {
            name        = "roks-create-worker-nodes-outbound"
            action      = "allow"
            destination = "161.26.0.0/16"
            source      = "0.0.0.0/0"
            direction   = "outbound"
        },
        {
            name        = "roks-nodes-to-service-inbound"
            action      = "allow"
            source      = "166.8.0.0/14"
            destination = "0.0.0.0/0"
            direction   = "inbound"
        },
        {
            name        = "roks-nodes-to-service-outbound"
            action      = "allow"
            destination = "166.8.0.0/14"
            source      = "0.0.0.0/0"
            direction   = "outbound"
        },
        # App Rules
        {
            name        = "allow-app-incoming-traffic-requests"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "inbound"
            tcp         = {
                port_min        = 1
                port_max        = 65535
                source_port_min = 30000
                source_port_max = 32767
            }
        },
        {
            name        = "allow-app-outgoing-traffic-requests"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "outbound"
            tcp         = {
                source_port_min = 1
                source_port_max = 65535
                port_min        = 30000
                port_max        = 32767
            }
        },
        {
            name        = "allow-lb-incoming-traffic-requests"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "inbound"
            tcp         = {
                source_port_min = 1
                source_port_max = 65535
                port_min        = 443
                port_max        = 443
            }
        },
        {
            name        = "allow-lb-outgoing-traffic-requests"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "outbound"
            tcp         = {
                port_min        = 1
                port_max        = 65535
                source_port_min = 443
                source_port_max = 443
            }
        }
    ]

  # Combine rules
  all_acl_rules = flatten([
    local.cluster_allow_rules,
    local.subnet_allow_rules,
    var.acl_rules
  ])
}

##############################################################################
