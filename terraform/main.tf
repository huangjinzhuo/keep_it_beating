/* 

Main configuration file for Terraform

Terraform configuration files are written in the HashiCorp Congiuration Language (HCL).
For more information on HCL syntax, visit: 

https://www.terraform.io/docs/configuration/syntax.html

 */

# Specify that we're using AWS, using the aws_region variable
provider "aws" {
  region   = "${var.aws_region}"
  version  = "~> 1.60.0"
}

# read the availability zones for the current region
data "aws_availability_zones" "all" {}


/* 

Configuration to make a very simple sandbox VPC for a few instances

For more details and options on the AWS vpc module, visit:
https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.30.0

 */
module "sandbox_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.30.0"

  name = "${var.fellow_name}-vpc"

  cidr             = "10.0.0.0/16"
  azs              = ["${data.aws_availability_zones.all.names}"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_vpn_gateway = true
  
  enable_s3_endpoint = true
  
  enable_dhcp_options              = true
  dhcp_options_domain_name         = "decentcore.com"
  dhcp_options_domain_name_servers = ["127.0.0.1", "8.8.8.8"]
  

/*
Get the allocated IPs as a parameter
Note that in the example we allocate 3 IPs because we will be provisioning 3 NAT Gateways (due to single_nat_gateway = false and having 3 subnets). If, on the other hand, single_nat_gateway = true, then aws_eip.nat would only need to allocate 1 IP. Passing the IPs into the module is done by setting two variables reuse_nat_ips = true and external_nat_ip_ids = ["${aws_eip.nat.*.id}"].
*/
  enable_nat_gateway  = true
  single_nat_gateway  = false
  reuse_nat_ips       = true                      # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids = ["${aws_eip.nat.*.id}"]   # <= IPs specified here as input to the module

 

  tags = {
    Owner       = "${var.fellow_name}"
    Environment = "dev"
    Terraform   = "true"
  }
}  


/*
External NAT Gateway IPs
By default this module will provision new Elastic IPs for the VPC's NAT Gateways. This means that when creating a new VPC, new IPs are allocated, and when that VPC is destroyed those IPs are released. Sometimes it is handy to keep the same IPs even after the VPC is destroyed and re-created. To that end, it is possible to assign existing IPs to the NAT Gateways. This prevents the destruction of the VPC from releasing those IPs, while making it possible that a re-created VPC uses the same IPs.
Then, pass the allocated IPs as a parameter to the VPC module.

To achieve this, allocate the IPs outside the VPC module declaration.
*/
resource "aws_eip" "nat" {
  count = 3
  vpc = true
}




/* 

Configuration for a security group within our configured VPC sandbox,
open to all ports for any networking protocol 

For more details and options on the AWS sg module, visit:
https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/1.9.0

Check out all the available sub-modules at:
https://github.com/terraform-aws-modules/terraform-aws-security-group/tree/master/modules

 */
module "open_all_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.9.0"

  name        = "open-to-all-sg"
  description = "Security group to make all ports publicly open...not secure at all"
  
  vpc_id                   = "${module.sandbox_vpc.vpc_id}"
  ingress_cidr_blocks      = ["10.0.0.0/16"]
  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_cidr_blocks      = ["10.0.0.0/16"]
  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Owner       = "${var.fellow_name}"
    Environment = "dev"
    Terraform   = "true"
  }
}

/* 

Configuration for a simple EC2 cluster of 4 nodes, 
within our VPC and with our open sg assigned to them

For all the arguments and options, visit:
https://www.terraform.io/docs/providers/aws/r/instance.html

Note: You don't need the below resources for using the Pegasus tool
  
 */

# Configuration for a "master" instance
resource "aws_instance" "cluster_master" {
    ami             = "${lookup(var.amis, var.aws_region)}"
    instance_type   = "m4.large"
    key_name        = "${var.keypair_name}"
    count           = 1

    vpc_security_group_ids      = ["${module.open_all_sg.this_security_group_id}"]
    subnet_id                   = "${module.sandbox_vpc.public_subnets[0]}"
    associate_public_ip_address = true
    
    root_block_device {
        volume_size = 100
        volume_type = "standard"
    }

    tags {
      Name        = "${var.cluster_name}-master-${count.index}"
      Owner       = "${var.fellow_name}"
      Environment = "dev"
      Terraform   = "true"
      HadoopRole  = "master"
      SparkRole  = "master"
    }

}

# Configuration for 3 "worker" elastic_ips_for_instances
resource "aws_instance" "cluster_workers" {
    ami             = "${lookup(var.amis, var.aws_region)}"
    instance_type   = "m4.large"
    key_name        = "${var.keypair_name}"
    count           = 3

    vpc_security_group_ids      = ["${module.open_all_sg.this_security_group_id}"]
    subnet_id                   = "${module.sandbox_vpc.public_subnets[0]}"
    associate_public_ip_address = true
    
    root_block_device {
        volume_size = 100
        volume_type = "standard"
    }

    tags {
      Name        = "${var.cluster_name}-worker-${count.index}"
      Owner       = "${var.fellow_name}"
      Environment = "dev"
      Terraform   = "true"
      HadoopRole  = "worker"
      SparkRole  = "worker"
    }

}


# Configuration for 3 "kafka broker" instances
resource "aws_instance" "kafka_broker" {
    ami             = "${lookup(var.amis, var.aws_region)}"
    instance_type   = "m4.large"
    key_name        = "${var.keypair_name}"
    count           = 3

    vpc_security_group_ids      = ["${module.open_all_sg.this_security_group_id}"]
    subnet_id                   = "${module.sandbox_vpc.public_subnets[0]}"
    associate_public_ip_address = true
    
    root_block_device {
        volume_size = 100
        volume_type = "standard"
    }

    tags {
      Name        = "${var.cluster_name}-broker-${count.index}"
      Owner       = "${var.fellow_name}"
      Environment = "dev"
      Terraform   = "true"
      KafkaRole  = "broker"
    }

}



# Configuration for 3 "kafka broker" instances
resource "aws_instance" "cassandra" {
    ami             = "${lookup(var.amis, var.aws_region)}"
    instance_type   = "m4.large"
    key_name        = "${var.keypair_name}"
    count           = 3

    vpc_security_group_ids      = ["${module.open_all_sg.this_security_group_id}"]
    subnet_id                   = "${module.sandbox_vpc.public_subnets[0]}"
    associate_public_ip_address = true
    
    root_block_device {
        volume_size = 100
        volume_type = "standard"
    }

    tags {
      Name        = "${var.cluster_name}-cassandra-${count.index}"
      Owner       = "${var.fellow_name}"
      Environment = "dev"
      Terraform   = "true"
      CassandraRole  = "cassandra"
    }

}



# Configuration for an Elastic IP to add to nodes
resource "aws_eip" "elastic_ips_for_instances" {
  vpc       = true
  instance  = "${element(concat(aws_instance.cluster_master.*.id, aws_instance.cluster_workers.*.id, aws_instance.kafka_broker.*.id, aws_instance.cassandra.*.id), count.index)}"
  count     = "${aws_instance.cluster_master.count + aws_instance.cluster_workers.count + aws_instance.kafka_broker.count + aws_instance.cassandra.count}"
}
