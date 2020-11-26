## Case study of moving a monolithic web application into a public cloud (AWS)

[Notejam](https://github.com/komarserjio/notejam) is a unified sample web application (more than just "Hello World") implemented using different server-side frameworks. For this study I chose the Javascript version.

Notejam is currently built as a monolith containing a built-in webserver and SQLite database.

![Notejam current architecture](https://www.dropbox.com/s/n40t5vnvhknj13x/notejam.png?raw=1)

### Business requirements

* The application must serve a variable amount of traffic. Most users are active during business hours. During big events and conferences the traffic could be 4 times more than typical.
* Notes should be preserved up to 3 years and recovered, if needed.
* Service continuity should be maintained in case of datacenter failures.
* The service must be capable of being migrated to any region supported by the cloud provider in case of an emergency.
* The target architecture must support more than 100 developers to work on, with multiple daily deployments, without interruption / downtime.
* The target architecture must provide separated environments to support processes for development, testing and deployment to production in the near future.
* Relevant infrastructure metrics and logs should be collected for quality assurance and security purposes.

### Additional aspects

* Operational excellence - Less infrastructure to manage is the better. In favor of managed services.
* Cost optimization - Prefer services when you only pay what you use.
* Reliability - In line with the business requiremens: a multi-datacenter architecture.
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
    * Open source
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

Both EKS and ECS meet the requirements. The costs are comparable, the operational efforts are comparable. ECS comes with a slightly less operational burden and it's tightly integrated with other AWS services. EKS meanwhile has the advantage of being an open source platform, backed with a huge community support and know-how. And also, using EKS would make easier to move the complete infrastructure to another vendor, or even establish a multi-vendor service strategy.

I chose ECS because the AWS integration, the slightly lower costs and the easier operational aspects.

### Target architecture

![Notejam target architecture](https://www.dropbox.com/s/as51vxq3h3hqoun/notejam-on-ecs-architecture.png?raw=1)

The architecture is not production ready by any means. It's fully functional but it's for demonstration purposes only.
#### Components

1. A single-region ECS cluster, running Fargate tasks in a VPC.
2. The VPC spans over 3 Availability Zones. For the sake of simplicity only public subnets are used.
3. The VPC is protected by a security group, only allowing incoming connections from the load balancer.
4. An application load balancer using an HTTP listener only.
5. An SQLite database mountend from EFS. SQLite is a wonderful, super fast database engine but it's not designed for using it in client-server applications. Changing the database backend however, would be beyond the scope of this exercise. In this case SQLite does its job (with some additional latency) because EFS implements the required [NFSv4 lock upgrading/downgrading](https://aws.amazon.com/about-aws/whats-new/2017/03/amazon-elastic-file-system-amazon-efs-now-supports-nfsv4-lock-upgrading-and-downgrading/) properly. EFS speed can be improved by using a provisioned performance mode.
6. ECR holds the container images
7. CloudWatch contains the application logs and relevant metrics. The new Conatiner Insights feature in CloudWatch provides excellent metrics out of the box.
8. CodePipeline for CI/CD. Not implemented yet.
9. ASW Backup for the database.

#### Deployment