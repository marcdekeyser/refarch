# Design Methodology
Building any type of workload on any sort of cloud platform requires a significant technical expertise, as well as an investment from the engineering side as there are  quite a few factors involved which introduce complexity. The age old adage of 'Measure twice, cut once' has never been truer than when designing for the cloud.

In order to build workloads the following topics should be clearly understood:

- The cloud platform you're deploying on
- Which services to use for your solution
- How the services should be configured
- How to optimally operationalize the used services
- Continuiously aligning with the latest best practices and service roadmaps.

Designing and building on the cloud is not a 'one-and-done' process, but rather a continuous improvement circle where the design and deployment gets reviewed for alignment on a regular cadence!

## Terminology
**SLA**: *Service Level Agreement* - (Promise) - An agremeement between provider and client about measurable metrics such as uptime, responsiveness, and responsibilities. The SLA agreement typically also include the consequences of living up to the made promises, such as financial penalties, service credits, or license extensions.
**SLO**: *Service Level Objective* - (Goal) - An agreement within an SLA about a specific metric, such as uptime or response time. Think of the SLA as the formal agreement between you and the customer, and the SLO(s) as the individual promises you're making to that customer.  
**SLI**: *Service Level Indicator* - (How did we do) - The measurement of compliance with an SLO.  
**RTO**: *Recovery Time Objective* - How long can an application be unavailable without causing significant damage to the business.
**RPO**: *Recovery Point Objective* - How much data can be tolerated losing during an unforteseen even.

## 1. Design for business requirements
Everything starts with clearly understanding the business requirements. Some workloads you deploy to the cloud will have different requirements, and even workloads in the same tier (f.e. Mission Critital) could have different requirements.

### Reliability
This is a relative concept, and workloads should reflect the reliability business requirements. 

| Reliability Tier | Permitted downtime (week) | Permitted downtime (month) | Permitted downtime (year) | 
|---|---|---|---|
| 99.9% | 10 minutes, 4 seconds | 43 minutes, 49 seconds | 8 hours, 45 minutes, 56 seconds |
| 99.95%| 5 minutes, 2 seconds | 21 minutes, 54 seconds | 4 hours, 22 minutes, 58 seconds |
| 99.99%| 1 minute | 4 minutes 22 seconds | 52 minutes, 35 seconds |
| 99.999%| 6 seconds | 26 seconds | 5 minutes, 15 seconds |
| 99.9999%| <1 second | 2 seconds | 31 seconds |

### Design principles
#### 1. Reliability
The fundamental persuit of the most reliable solution, ensuring trade-offs are properly understood.  

**Active/Active design**  
To maximize availability and achieve regional fault tolerance, solution components should be distributed across multiple Availability Zones and Azure regions using an active/active deployment model where possible.

**Blast radius reduction and fault isolation**  
Failure is impossible to avoid in a highly distributed multi-tenant cloud environment like Azure. By anticipating failures and correlated impact, from individual components to entire Azure regions, a solution can be designed and developed in a resilient manner.

**Observe application health**  
Before issues impacting application reliability can be mitigated, they must first be detected and understood. By monitoring the operation of an application relative to a known healthy state it becomes possible to detect or even predict reliability issues, allowing for swift remedial action to be taken.

**Drive automation**  
One of the leading causes of application downtime is human error, whether that is due to the deployment of insufficiently tested software or misconfiguration. To minimize the possibility and impact of human errors, it's vital to strive for automation in all aspects of a cloud solution to improve reliability; automated testing, deployment, and management.

**Design for self-healing**  
Self healing describes a system's ability to deal with failures automatically through pre-defined remediation protocols connected to failure modes within the solution. It's an advanced concept that requires a high level of system maturity with monitoring and automation, but should be an aspiration from inception to maximize reliability.

**Complexity avoidance**  
Avoid unnecessary complexity when designing the solution and all operational processes to drive reliability and management efficiencies, minimizing the likelihood of failures.

#### 2. Performance efficiency
Design for scalability across the end-to-end solution without performance bottlenecks.

**Design for scale-out**  
Scale-out is a concept that focuses on a system's ability to respond to demand through horizontal growth. This means that as traffic grows, more resource units are added in parallel instead of increasing the size of the existing resources. A systems ability to handle expected and unexpected traffic increases through scale-units is essential to overall performance and reliability by further reducing the impact of a single resource failure.

**Automate scaling**  
Scale operations should be fully automated to minimize the performance or availability impact from (un)expected increases in traffic.

**Continuous validation and testing**
Automated testing should be performed within the CI/CD process to drive continuous validation for each application change. Load testing against a performance baseline should be implemented to valide thresholds, targets, and assumptions. These test should be executed against testing and staging environments. When using Blue/Green deployments models it is beneficial to run a subset of tests against the production environment to validate new deployments.

**Reduce overhead**  
Using managed compute services and containerized architectures significantly reduces the ongoing administrative and operational overhead of designing, operating, and scaling applications by shifting infrastructure deployment and maintenance to the managed service provider.

**Baseline performance and identify bottlenecks**  
Performance testing with detailed telemetry from every system component allows for the identification of bottlenecks within the system, including components that need to be scaled in relation to other components, and this information should be incorporated into a capacity model.

**Model capacity**  
A capacity model enables planning of resource scale levels for a given load profile, and additionally exposes how system components perform in relation to each other, therefore enabling system-wide capacity allocation planning.

#### 3. Operational Excellence
Engineered to last with robust and assertive operational management.

**Loosely coupled components**  
Loose coupling enables independent and on-demand testing, deployments, and updates to components of the application while minimizing inter-team dependencies for support, services, resources, or approvals.

**Automate build and release processes **  
Fully automated build and release processes reduce the friction and increase the velocity of deploying updates, bringing repeatability and consistency across environments. Automation shortens the feedback loop from developers pushing changes to getting insights on code quality, test coverage, resiliency, security, and performance, which increases developer productivity.

**Developer agility**  
Continuous Integration and Continuous Deployment (CI/CD) automation enables the use of short-lived development environments with lifecycles tied to that of an associated feature branch, which promotes developer agility and drives validation as early as possible within the engineering cycle to minimize the engineering cost of bugs.

**Quantify operational health**	  
Full diagnostic instrumentation of all components and resources enables ongoing observability of logs, metrics and traces, but also facilitates health modeling to quantify application health in the context to availability and performance requirements.

**Rehearse recovery and practice failure**  
Business Continuity (BC) and Disaster Recovery (DR) planning and practice drills are essential and should be conducted frequently, since learnings can iteratively improve plans and procedures to maximize resiliency in the event of unplanned downtime.

**Embrace continuous operational improvement**  
Prioritize routine improvement of the system and user experience, using a health model to understand and measure operational efficiency with feedback mechanisms to enable application teams to understand and address gaps in an iterative manner.

#### 4. Security
Design for end-to-end security to maintain application stability and ensure availability.

**Monitor the security of the entire solution and plan incident responses**  
Correlate security and audit events to model application health and identify active threats. Establish automated and manual procedures to respond to incidents using Security Information and Event Management (SIEM) tooling for tracking.

**Model and test against potential threats**
Ensure appropriate resource hardening and establish procedures to identify and mitigate known threats, using penetration testing to verify threat mitigation, as well as static code analysis and code scanning.

**Identify and protect endpoints**
Monitor and protect the network integrity of internal and external endpoints through security capabilities and appliances, such as firewalls or web application firewalls. Use industry standard approaches to protect against common attack vectors like Distributed Denial-Of-Service (DDoS) attacks, such as SlowLoris.

**Protect against code level vulnerabilities**  
Identify and mitigate code-level vulnerabilities, such as cross-site scripting or SQL injection, and incorporate security patching into operational lifecycles for all parts of the codebase, including dependencies.

**Automate and use least privilege**
Drive automation to minimize the need for human interaction and implement least privilege across both the application and control plane to protect against data exfiltration and malicious actor scenarios.

**Classify and encrypt data**  
Classify data according to risk and apply industry standard encryption at rest and in transit, ensuring keys and certificates are stored securely and managed properly.

#### 5. Cost optimization
Introducing greater reliability and security obviously impacts your operational costs, the tradeoffs should be carefully considered in the context of workload requirements.

Maximizing reliability can impact the overall financial cost of the solution. For example, the duplication of resources and the distribution of resources across regions to achieve high availability has clear cost implications. To avoid excess costs, don't over-engineer or over-provision beyond the relevant business requirements.

Also, there is added cost associated with engineering investment in fundamental reliability concepts, such as embracing infrastructure as code, deployment automation, and chaos engineering. This comes at a cost in terms of both time and effort, which could be invested elsewhere to deliver new application functionality and features.