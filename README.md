# Scalable AWS Web Architecture with Terraform

This repository contains the Terraform code for the portfolio project for the **Cloud Programming (DLBSEPCP01_E)** course at IU International University of Applied Sciences.

The project deploys a scalable, highly available, and low-latency web architecture on Amazon Web Services (AWS). It is designed to host a simple "Hello World" webpage, demonstrating core cloud architecture principles and the use of Infrastructure as Code (IaC).

## Architecture Overview

The Terraform configuration will deploy the following AWS resources:
-   **VPC:** A custom Virtual Private Cloud with public and private subnets across two Availability Zones for network isolation and high availability.
-   **Internet Gateway & NAT Gateway:** An Internet Gateway to allow public access to the load balancer and a NAT Gateway to allow private instances secure outbound internet access for software updates.
-   **Application Load Balancer (ALB):** Distributes incoming web traffic across the backend servers.
-   **Auto Scaling Group:** Automatically manages the number of EC2 instances to handle traffic loads and replaces unhealthy instances.
-   **EC2 Instances:** `t2.micro` instances running Amazon Linux 2, configured with a `user_data` script to automatically install an Apache web server.
-   **CloudFront Distribution:** A Content Delivery Network (CDN) to cache the website content at edge locations globally, providing low-latency access to users.
-   **Security Groups:** Acts as a virtual firewall to control traffic to the ALB and EC2 instances.

## Prerequisites

Before you begin, ensure you have the following installed and configured:
1.  **Terraform:** [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2.  **AWS CLI:** [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
3.  **AWS Credentials:** Your local machine must be configured with AWS credentials. You can do this by running `aws configure` and providing your Access Key ID and Secret Access Key.

## How to Use

1.  **Clone the Repository:**
    ```bash
    git clone [Your-GitHub-Repo-URL]
    cd [repository-folder-name]
    ```

2.  **Initialize Terraform:**
    This command downloads the necessary AWS provider plugin.
    ```bash
    terraform init
    ```

3.  **Review the Execution Plan:**
    This command shows you all the resources that will be created without making any changes.
    ```bash
    terraform plan
    ```

4.  **Apply the Configuration:**
    This command builds the infrastructure in your AWS account. You will need to type `yes` to confirm.
    ```bash
    terraform apply
    ```

5.  **Destroy the Infrastructure:**
    **Important:** After you are finished, run this command to delete all the resources from your AWS account to avoid incurring costs. You will need to type `yes` to confirm.
    ```bash
    terraform destroy
    ```

## Outputs

After a successful `apply`, Terraform will output the following:
-   `cloudfront_domain_name`: The public URL for your website.
-   `alb_dns_name`: The internal DNS name for the Application Load Balancer.