# static-site-tf

#### Pre-requisites

1. Access to a minimum of set of AWS resources is required, else administrator access to AWS would be ideal.
2. Terraform state is local state for simplicity.
3. For this exercise I am exporting the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for a test account I have on my personal AWS account.  I am sure you all have IAM roles and profiles you assume per your accounts/environments, but wanted to make a note just in case.

eg:

```bash
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
```

#### Stack

Cloudfront, an s3 bucket, cloudwatch and WAF as the infrastructure (AWS services) used to deploy the Single Page Application.

#### Why?

1. Single page application, there is no need to provision subnets, networks, albs, gateways or routing tables to provide access to the application.
2. I do believe this is more cost effective, a lot less resources to provision, keeping cost down.
3. Based on AWS documentation the above resources are a minimum for a single page application.
4. It seemed easier to write the code to provision the resources and less work :).

### Steps to provision, deploy and destroy the application and aws resources

1. Clone repo
   1. `git clone git@github.com:smetroid/static-site-tf.git`
2. Download terraform modules and plugins
   1. `terraform init`
3. Provision and deploy the application
   1. `terraform apply`
4. Go to the CloudFront URL found in the output when terraform apply finishes
  eg:

  ```bash
  Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

  Outputs:

  app_url = {
    "dev-spa" = "d6xtsfw2dnceh.cloudfront.net"
  }
  ````

#### Steps to destroy the resources and the application

1. terraform destroy
