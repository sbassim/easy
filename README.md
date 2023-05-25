Welcome to Plains New GitHub repo!



## Setup

### Windows systems
#### Terraform CLI

- Download [Terraform](https://developer.hashicorp.com/terraform/downloads) depending on your system
- Export `.exe` executable to directory of choice, e.g., `c:\www\terraform`
- Update the global `PATH` variable from `System Environment Variables`
- Verify the configuration `terraform -version`


#### AWS CLI

- Download and install aws cli from powershell `msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi`
- Follow instructions
- Verify aws cli `aws --version`
- Configure your AWS with `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` and `AWS_SESSION_TOKEN` automatically with `SSO`:
    - Create new IAM user
    - Assign User to Group e.g., `admin`
    - Set permissions for the Group e.g., `AdministratorAccess`
    - Follow [instructions](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html#sso-configure-profile-token-auto-sso) with `aws configure sso`
    - `SSO start url` and `SSO region` will be provided
    - Define a profile name `admin`
    - Test setup with `aws s3 ls --profile admin`


### Create Infrastructure

- Inside the repo `terraform init` to initialize the backend and install providers and plugins
- Format the repo `terraform fmt` (optional but important)
- AWS Lambdas are serverless, so only provide the code to execute
- Zip the code (manually or within `null_resource` from terraform)
- Ensure that the zip file is less than 50MB; if it's larger, you'll have to upload it to an S3 bucket 
- Validate configurations with `terraform validate`
- Check configuration `terraform plan`
- Apply and create infrastructure `terraform apply`
- Inspect the state of the infrastructure `terraform show`


### Destroy Infrastructure

Once the infrastructure isnt used, destroy it to reduce security exposure and costs. For example, removing a production environment, build or testing systems.

- Destroy with `terraform destroy`


## Lambdas
### IAM Roles

Need to make sure IAM role used for your Lambda functions has the necessary permissions to create network interfaces on EC2. Yes EC2 (see `### Permissions`)

```shell
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
```

### Permissions

When a Lambda function is deployed inside a VPC, it needs to create ENIs (Elastic Network Interfaces) for network communication, so the IAM role requires certain EC2 permissions.

```shell
data "aws_iam_policy_document" "iam_for_lambda_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]

    resources = ["*"]
  }
}
```

### Subnets

1. Open your favorite web browser and navigate to the AWS Management Console and log in.
2. While in the Console, click on the search bar at the top, search for ‘vpc’, and click on the VPC menu item. 
3. Once on the VPC page, click on Your VPCs. You should see the VPC created with the same ID Terraform returned earlier. 
4. Since Terraform created more than just the VPC resource but all of the resources required for the VPC, you should then find each resource on this page also. 

#### Fixing CIDR ranges

If the VPC has a CIDR block of 10.0.0.0/16, it encompasses all IP addresses from 10.0.0.0 to 10.0.255.255. The subnets must fall within this range. The following would work great.

```shell
variable "dev_vpc_cidr" {
  description = "CIDR block for the development VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dev_subnets" {
  description = "CIDR block for the development subnets"
  type        = string
  default     = "10.0.1.0/24"
}

variable "prod_vpc_cidr" {
  description = "CIDR block for the production VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "prod_subnets" {
  description = "CIDR block for the production subnets"
  type        = string
  default     = "10.1.1.0/24"
}
```