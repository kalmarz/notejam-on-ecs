### Case study of moving a monolithic web application into a public cloud

[Notejam](https://github.com/komarserjio/notejam) is a unified sample web application (more than just "Hello World") implemented using different server-side frameworks. For this study I chose the Javascript version.

Notejam is currently built as a monolith containing a built-in webserver and SQLite database.

![Notejam current architecture](https://www.dropbox.com/s/n40t5vnvhknj13x/notejam.png?raw=1)

#### Business requirements

* The application must serve a variable amount of traffic. Most users are active during business hours. During big events and conferences the traffic could be 4 times more than typical.
* Notes should be preserved up to 3 years and recover it if needed.
* Service continuity should be kept in case of datacenter failures
* The service must be capable of being migrated to any region supported by the cloud provider in case of an emergency.
* The target architecture must support more than 100 developers to work on, with multiple daily deployments, without interruption / downtime.
* The target architecture must provide separated environments to support processes for development, testing and deployment to production in the near future.
* Relevant infrastructure metrics and logs should be collected for quality assurance and security purposes.