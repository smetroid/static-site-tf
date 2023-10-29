### Objective

Your assignment is to build a terraform configuration that sets up hosting
for the provided index.html file.

### Brief

The crew on the Millennium Falcon is bored. To bolster morale, one of your team members has developed a simple game in the form of a single-page application. You have offered to help her with the setup of the infrastructure side of things.

Your colleague believes that this app will be immensely popular, but has asked that
before it is publically available that it can only be accessed by her in order
to ensure that it meets the required standards.

### Tasks

-   Implement a terraform configuration to create the required infrastructure on AWS.
-   Use terraform to 'deploy' the index.html ( application ) on the AWS infrastructure.
-   Ensure that the application can only be accessed from: 3.121.56.176

### Deliverables

Make sure to include all source code in this repository.

Please provide brief documentation as to why you chose a particular stack/setup.

Ensure that your terraform code can be executed and create the infrastructure
required and 'deploy' the single-page application.

You may use local state or remote state if you so choose.

### Evaluation Criteria

-   Terraform best practices.
-   Choice of infrastructure
-   Completeness: did you complete the features?
-   Correctness: does the functionality act in sensible, thought-out ways?
-   Maintainability: is it written in a clean, maintainable way?

### CodeSubmit

Please organize, design, test, and document your code as if it were
going into production - then push your changes to the master branch. After you have pushed your code, you may submit the assignment on the assignment page.

All the best and happy coding,

The SpyCloud Team

---

### Solution

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

I choose to use cloudfront, an s3 bucket, cloudwatch and WAF as the infrastructure (AWS services) used to deploy the Single Page Application.

#### Why?

1. It's a single page application, there is no need to provision subnets, networks, albs, gateways or routing tables to provide access to the application.
2. I do believe this is more cost effective, a lot less resources to provision, keeping cost down.
3. Based on AWS documentation the above resources are a minimum for a single page application.
4. It seemed easier to write the code to provision the resources and less work :).

### Steps to provision, deploy and destroy the application and aws resources

1. Clone repo
   1. `git clone http://spycloud-pwbcjf@git.codesubmit.io/spycloud/spycloud-devops-challenge-1-qsmutt`
2. Initialize terraform resources
   1. `terraform init`
3. Provision and deploy the application
   1. `terraform apply`
4. Go to the cloudfront url found in the output when terraform apply finishes
  eg:

  ```bash
    Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

  Outputs:

  app_url = {
    "dev-spa-spycloud" = "d3l7fde3o4uchq.cloudfront.net"
  }
  ````

#### Steps to destroy the resources and the application

1. terraform destroy
