
# Keep_It_Beating


## Table of Contents
1. [Heart Rate Monitor](README.md#Heart_Rate_Monitor)
1. [Auto Deployment](README.md#Auto_Deployment)
1. [Requirements](README.md#Requirements)
1. [Platform Architecture](README.md#Platform_Architecture)
1. [Challenge](README.md#Challenge)



## Heart Rate Monitor

Heart Rate Moniotor is an Insight engineered application that takes in real-time streaming data to produce ECG records and display irregular patient information. The application could be used by healthcare providers to monitor any life-threathening events or to diagnose cardiac arrhythmia.


## Auto Deployment

This DevOps project was to deploy the application data pipeline infrastructure with just one-click by using Terraform. Here are the core packages used in Heart Rate Monitor:

Python 3.6
Nginx, Gunicorn and Flask
Cassandra cluster
Spark Streaming cluster
Kafka cluster
S3 Bucket


## Security Group Auto Remedy

Second challenge is to automate some security remedy by using Cloud Trail, CloudWatch, and Lambda.


## Requirements


Terraform : https://learn.hashicorp.com/terraform/getting-started/install.html
AWS-IAM : https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
AWS Credential: Export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY to Host Environment



## Platform Architecture

file:///C:/Users/jin_h/Downloads/Keep_It_Beating.svg



## Challenge

* One-click deployment to deploy servers in various requirement.
* Auto remedy when special security group is changed.


