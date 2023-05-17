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
    - Follow [instructions](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html#sso-configure-profile-token-auto-sso)
    - `SSO start url` and `SSO region` will be provided
    - Define a profile name `admin`
    - Test setup with `aws s3 ls --profile admin`