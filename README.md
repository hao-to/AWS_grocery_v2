# GroceryMate – Cloud Journey Edition 🛒☁️

Welcome to my humble fork of the GroceryMate app – originally developed by my AWS Cloud tutor and mentor at Masterschool's Software Engineering bootcamp. So, this repo is not the original masterpiece, but a chronicle of my hands-on journey through various AWS topics, one weekly task at a time.

## 🧭 Table of Contents

- [What Was Actually Done](#what-was-actually-done)
- [Architecture Diagram](#architecture-diagram)
- [How to Run (Optional)](#how-to-run-optional)
- [Demo Videos](#demo-videos)
- [Reflections](#reflections)

## 📦 What Was Actually Done

- Ran the app locally to understand the base setup
- Connected to AWS and launched an EC2 instance in the default VPC
- Connected to the EC2 instance and ran basic Linux commands
- Forked the GroceryMate repo and deployed it on EC2
- Made the app accessible via browser
- Attached an Elastic Load Balancer (ALB)
- Configured a security group to protect the EC2 instance
- Wrote a Dockerfile and tested the app locally and on EC2
- Created an RDS PostgreSQL database and connected the app to it
- Secured the RDS instance (private subnet, encryption, SG rules)
- Set up an 'infrastructure/' folder and started using Terraform (or as I call it TERRORform)
- Defined EC2, SG, and RDS resources in Terraform
- Created an S3 bucket via Terraform and uploaded avatar images via AWS CLI
- Created a custom IAM role for EC2 to access the S3 bucket
- Set up a basic CloudWatch alarm as the final weekly task in my role based learning journey
- Cleaned up unused resources to avoid unnecessary AWS costs
- Finalized project structure and wrote this README

🔸 Note: I didn’t set up an Auto Scaling Group (ASG). It would’ve made sense together with the ALB, but it was optional and by then my brain, with its own ASG, had already scaled down to zero instances.
 
## 🗺️ Architecture Diagram
![AWS Architecture Diagram](assets/aws-architecture-diagram.png)
