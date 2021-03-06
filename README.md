## Case study: moving a monolithic web application into a public cloud (AWS)

[Notejam](https://github.com/komarserjio/notejam) is a unified sample web application (more than just "Hello World") implemented using different server-side frameworks. For this study I chose the Javascript version.

Notejam is currently built as a monolith containing a built-in webserver and SQLite database.

![Notejam current architecture](https://www.dropbox.com/s/n40t5vnvhknj13x/notejam.png?raw=1)

### Business requirements

* The application must serve a variable amount of traffic. Most users are active during business hours. During big events and conferences, the traffic could be 4 times more than typical.
* Notes should be preserved up to 3 years and recovered, if needed.
* Service continuity should be maintained in case of datacenter failures.
* The service must be capable of being migrated to any region supported by the cloud provider in case of an emergency.
* The target architecture must support more than 100 developers to work on, with multiple daily deployments, without interruption / downtime.
* The target architecture must provide separated environments to support processes for development, testing and deployment to production in the near future.
* Relevant infrastructure metrics and logs should be collected for quality assurance and security purposes.

### Additional aspects

* Operational excellence - Less infrastructure to manage is the better. In favor of managed services.
* Cost optimization - Prefer services when you only pay what you use.
* Reliability - In line with the business requirements: a multi-datacenter architecture.
* Performance efficiency - Optimize the resource allocations for the actual usage.
* Security - Apply security best practices and principles.

### Contenders

* **Lift & Shift**
  * It's quick and easy however it wouldn't fit most of the requirements
* **EC2 VM** based, fault-tolerant, multi-AZ infrastructure
  * Pros
    * Can be designed in a way to fit the requirements
    * Full control over every elements of the infrastructure
  * Cons
    * It takes some time to build
    * Big operational overhead
    * Paying for idle resources
* **EC2 based Kubernetes** cluster
  * Pros
    * Can be designed in a way to fit the requirements
    * Full control over every elements of the infrastructure
    * Open-source
  * Cons
    * Same as for the EC2 VM approach
    * Probably an overkill in this case
* **EKS** - managed Kubernetes cluster
  * Pros
    * Same as for the EC2 based Kubernetes approach
    * Managed control plane
    * Pay as you go with Fargate
  * Cons
    * Control plane has additional cost
    * The integration with other AWS services is not so tight
* **ECS** - AWS's own managed container platform
  * Pros
    * Fully managed
    * Free control plane
    * Tightly integrated with other AWS services
    * Pay as you go with Fargate
  * Cons
    * Proprietary product -> vendor lock-in?

Both EKS and ECS meet the requirements. The costs are comparable, the operational efforts are comparable. ECS comes with a slightly less operational burden and it's tightly integrated with other AWS services. EKS meanwhile has the advantage of being an open-source platform, backed with a huge community support and know-how. And also, using EKS would make easier to move the complete infrastructure to another vendor, or even establish a multi-vendor service strategy.

I chose ECS because the AWS integration, the slightly lower costs and the easier operational aspects.

### Target architecture

![Notejam target architecture](https://www.dropbox.com/s/as51vxq3h3hqoun/notejam-on-ecs-architecture.png?raw=1)

The architecture is not production ready by any means. It's fully functional but it's for demonstration purposes only.
#### Components

1. A single-region ECS cluster, running Fargate tasks in a VPC.
2. The VPC spans over 3 Availability Zones. For the sake of simplicity only public subnets are used.
3. The VPC is protected by a security group, only allowing incoming connections from the load balancer.
4. An application load balancer using only an **HTTP** listener! It's not secure, I know. :)
5. An SQLite database mounted from EFS. SQLite is a wonderful, super-fast database engine but it's not designed for using it in client-server applications. Changing the database backend, however, would be beyond the scope of this exercise. In this case SQLite does its job (with some additional latency) because EFS implements the required [NFSv4 lock upgrading/downgrading](https://aws.amazon.com/about-aws/whats-new/2017/03/amazon-elastic-file-system-amazon-efs-now-supports-nfsv4-lock-upgrading-and-downgrading/) properly. EFS speed can be improved by using a provisioned performance mode.
6. ECR holds the container images
7. CloudWatch contains the application logs and relevant metrics. The new Container Insights feature provides excellent metrics out of the box.
8. CodePipeline for CI/CD. Not implemented yet.
9. AWS Backup for the database. Not implemented yet.

### Deployment

1. Clone this repository
2. Set the required AWS region in `infra/vars.tf`
3. Export your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as environment variables
4. `cd infra && terraform init`
5. `terraform apply`<sup>*</sup>

(<sup>*</sup> Known bug: `terraform apply` will fail when creating EFS mount targets because the VPC subnet IDs can't yet be determined. Running `terraform apply` again fixes the issue and creates the missing resources.)

#### The Terraform files

* `vars.tf` - holds the variables
* `vpc.tf` - defines the VPC
* `securitygroup.tf` - configures the security groups
* `iam.tf` - creates the task execution role for ECS
* `efs.tf` - creates the EFS volume and the mount targets in the Availability Zones
* `lb.tf` - creates an application load balancer
* `cloudwatch.tf` - log group for ECS tasks
* `ecr.tf` - creates the container registry, builds, tags and pushes the Docker image to ECR using a local-exec
* `ecs.tf` - creates the ECS cluster
* `ecs-task-definition.tf` - creates the task and container definitions
* `ecs-service.tf` - provides the ECS service
* `ecs-autoscaling.tf` - adds autoscaling capability to the ECS service

#### Compliance with business requirements

- [*] Handles variable amount of traffic using load balancing and autoscaling.
- [*] Resistant to datacenter failures because of the multi-Az setup and the resiliency of the managed AWS services.
- [*] The application can easily be migrated to another region within minutes.
- [*] The database is regularly backed up and can be restored if needed.
- [*] The application can easily be integrated with CodePipeline, providing CI/CD for the developers.
- [*] Ability to create separate environments for development, staging, etc. by setting the `ENV` variable in `vars.tf` (moving Terraform state to a cloud backend like S3, and using Terraform workspaces is preferred)
- [*] Relevant infrastructure metrics and logs are collected in CloudWatch.