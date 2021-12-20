##############################################################################
# IBM Cloud Region
##############################################################################

variable region {
  description = "Region where VPC will be created"
  type        = string
  default     = "us-south"

  validation {
    error_message = "Region can only be `us-south`,`eu-de`,`eu-gb`,`js-osa`,`br-sao`,`jp-tok`,`au-syd`,`ca-tor`,`us-east`."
    condition     = contains(
      [
        "us-south",
        "eu-de",
        "eu-gb",
        "js-osa",
        "br-sao",
        "jp-tok",
        "au-syd",
        "ca-tor",
        "us-east"
      ],
      var.region
    )
  }
}

##############################################################################