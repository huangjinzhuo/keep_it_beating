/* 

Terraform file to define which variables are used

This is NOT where you set the variables. Instead, they should be 
set at the command line, with .tfvars files, or with environment variables

 */

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "keypair_name" {
	description = "The name of your pre-made key-pair in Amazon (e.g. david-IAM-keypair )" 
} 

variable "bastian_keypair_name" {
	description = "The name of your pre-made key-pair in Amazon (e.g. david-IAM-keypair )" 
} 

variable "fellow_name" {
  description = "The name that will be tagged on your resources."
}

variable "amis" {
  type = "map"
  default = {
    "us-west-2" = "ami-060eece82fbcf60c9"
    kafka = "ami-0ac32ff18b7e18d36"                 # this is postgress ami. need to change the image
    spark = "ami-09550b84dfba8f5cf"
    cassandra = "ami-0ac32ff18b7e18d36"             # this is postgress ami. need to change the image
    flask = "ami-073264bd0fc497f34"
    ubuntu = "ami-ba602bc2"
  }
}

variable "cluster_name" {
	description = "The name for your instances in your cluster" 
	default 	= "beats_cluster"
}

variable "instance_type" {
    description = "The type for your instances in your cluster"
    default     = "t2.micro"
}
/*	

Not using AWS credential variables since they're automatically detected 
from the environment variables

However, you could remove this and use a **properly** secured variable file
If you prefer to use a variable file, then you should NOT commit that file 
and should use a proper security measures (e.g. use .gitignore, restrict access)

It is also worth noting that Terraform stores state in plaintext, so should
be used in production with a remote backend that is encrypted (e.g. S3, Consul)

variable "aws_access_key" {
	description = "AWS access key (e.g. ABCDE1F2G3HIJKLMNOP )"	
}

variable "aws_secret_key" {
	description = "AWS secret key (e.g. 1abc2d34e/f5ghJKlmnopqSr678stUV/WXYZa12 )"	
}

 */ 
