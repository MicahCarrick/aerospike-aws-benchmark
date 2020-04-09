# Project Name
# 
# A name for the project which will be used to create AWS 'Name' tags as well
# as a 'Project' tag.

variable "project_name" {
    type    = string
    default = "Aerospike Benchmark"
}

# Key Name
# 
# A name of an EC2 Key Pair already available in the region.
#
# See: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html

variable "key_name" {
    type    = string
    default = null
}

# Region
#
# AWS Region in which to provision all infrastructure.

variable "region" {
    type    = string
    default = "us-west-2"
}

# Availability Zones
#
# A list of availability zones in which to provision instances for Aerospike
# Server nodes. A public/private subnet, NAT, and instances will be provisioned
# in each AZ.

variable "availability_zones" {
    type    = list
    default = ["us-west-2a", "us-west-2b"]
}

# SSH Ingress CIDRs
#
# AWS account that owns the aerospike server and benchmark client AMIs

variable "ami_owner" {
    type    = "string"
    default = "696609415687"
}

# NAT Instance Type
#
# The EC2 instance type to use for the NAT instances if 'nat_type' = 'instance'.
#
# See: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html

variable "nat_instance_type" {
    type    = "string"
    default = "t2.micro"
}

# Aerospike Instance Count
#
# The number of nodes in the Aerospike cluster. One EC2 instance will be created
# for each node and spread across AZs.

variable "aerospike_instance_count" {
    type    = number
    default = 2
}

# Aerospike Instance Type
#
# The EC2 instance type to use for Aerospike nodes. Typically these are instance
# types which have SSD Instance Store Volumes such as the m5d, r5d, c5d, i3, and
# i3en instance families.

variable "aerospike_instance_type" {
    type    = string
    default = "m5d.8xlarge"
}

# Client Instance Count
#
# The number of nodes in the client cluster. One EC2 instance will be created
# for each node and spread across AZs.

variable "client_instance_count" {
    type    = number
    default = 2
}

# Client Instance Type
#
# The EC2 instance type to use for client nodes.

variable "client_instance_type" {
    type    = string
    default = "m5.8xlarge"
}

# SSH Ingress CIDRs
#
# CIDR of allowed SSH connections to both clients and servers

variable "ssh_ingress_cidrs" {
    type    = list
    default = ["0.0.0.0/0"]
}

variable "vpc_cidr" {
    type    = string
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    type    = list
    default = ["10.0.128.0/20","10.0.144.0/20","10.0.160.0/20","10.0.176.0/20"]
}

variable "private_subnet_cidr" {
    type    = list
    default = ["10.0.0.0/19","10.0.32.0/19","10.0.64.0/19","10.0.96.0/19"]
}
