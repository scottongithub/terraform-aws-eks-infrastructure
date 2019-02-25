
variable "region"{
  default     = "us-east-1"
}

variable "k8s_vpc_CIDR" {
  default     = "10.0.0.0/16"
}

variable "public_subnet-01_AZ" {
  default     = "us-east-1b"
}

variable "public_subnet-02_AZ" {
  default     = "us-east-1c"
}

variable "private_subnet-01_AZ" {
  default     = "us-east-1a"
}

variable "private_subnet-02_AZ" {
  default     = "us-east-1c"
}

variable "public_subnet-01_CIDR" {
  default     = "10.0.12.0/24"
}

variable "public_subnet-02_CIDR" {
  default     = "10.0.13.0/24"
}

variable "private_subnet-01_CIDR" {
  default     = "10.0.14.0/24"
}

variable "private_subnet-02_CIDR" {
  default     = "10.0.15.0/24"
}

########################
#ElasticSearch options
########################

#toggles ES feature
variable "enable_es" {
  default     = "true"
}

variable "es_ebs_volume_type" {
  default     = "gp2"
}

variable "es_ebs_volume_size" {
# in GB
  default     = "10"
}

variable "es_ebs_instance_type" {
  default     = "t2.small.elasticsearch"
}

########################
#Enable private subnets?
########################

variable "enable_priv_subs" {
  default    = "true"
  }
