### Introduction
* This demo uses the cloudpose's library to build EC2 in the VPC. And then, install mattermost team edition, version 7.0.1 in EC2 instance by using ```remote-exec```
* The AWS structure is in AWS account that accessed via gateway account.
#### Get session token
edit ```get_token.sh```
- <profile-name> name of file in ~/.aws/config that similar as
```
role_arn=arn:aws:iam::<account-id>:role/infras_admin
source_profile=<access key profile>
mfa_serial=arn:aws:iam::<gateway account id>:mfa/<user-name>
```
- <account-id>: account that contains all resource (ec2, ...)
Run command: ```get_token.sh```
#### Build structure
1. Run: ```terraform init```
2. Run ```terraform plan -var-file feature.tfvars```
