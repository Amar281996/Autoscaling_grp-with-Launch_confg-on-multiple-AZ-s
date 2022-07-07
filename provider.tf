#terraform Required Providers 
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }  
 }     
 provider "aws" {
    region = var.region
    profile = "default"
 }