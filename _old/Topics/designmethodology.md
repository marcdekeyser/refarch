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

## 2. Reliability design principles
Outages and malfunctions are serious concerns for all workloads. A reliable workload must survive those events and continue to consistently provide its intended functionality. It must be resilient so that it can detect, withstand, and recover from failures within an acceptable time period. It must also be available so that users can access the workload during the promised time period at the promised quality level.

It's not realistic to assume failures won't occur, especially when the workload is built to run on distributed systems. Some components might fail while others continue to operate. At some point, the user experience might be affected, which compromises business goals.

Workload architectures should have reliability assurances in application code, infrastructure, and operations. Design choices shouldn't change the intent that's specified by business requirements. Such changes should be considered significant tradeoffs.

The design principles are intended to provide guidance for aspects of reliability that you should consider throughout the development lifecycle. Start with the recommended approaches and justify the benefits for a set of requirements.

### Design for business requirements
|![](/images/goal.svg)|**Gather business requirements with a focus on the intended utility of the workload.**|
|---|---|
Requirements must cover user experience, data, workflows, and characteristics that are unique to the workload. The outcome of the requirements process must clearly state the expectations. The goals must be achievable and negotiated with the team, given a specified investment. They must be documented to drive technological choices, implementations, and operations.

**Quantify success by setting targets on indicators for individual components, system flows, and the system as a whole. Do those targets make user flows more reliable?**  
Metrics quantify expectations. They enable you to understand complexities and determine whether the downstream costs of those complexities are within the investment limit.

The target values indicate an ideal state. You can use the values as test thresholds that help you detect deviations from that state and how long it takes to return to the target state.

Compliance requirements must also have predictable outcomes for in-scope flows. Prioritizing these flows bring attention to areas that are the most sensitive.

**Understand platform commitments. Consider the limits, quotas, regions, and capacity constraints for services.**  
Service-level agreements (SLAs) vary by service. Not all services and features are covered equally. Not all services or features are available in all regions. Most of the subscription resource limits are per region. Having a good understanding of coverage and limits can help you detect drift and build resiliency and recovery mechanisms.

**Determine dependencies and their effect on resiliency.**  
Keeping track of dependent infrastructure, services, APIs, and functions developed by other teams or third parties helps you determine whether the workload can operate in absence of those dependencies. It also helps you understand cascading failures and improve downstream operations.

Developers can implement resilient design patterns to handle potential failures when you use external services that might be susceptible to failures.

### Design for resilience
|![](/images/goal.svg)|**The workload must continue to operate with full or reduced functionality.**|
|---|---|

**Distinguish components that are on the critical path from those that can function in a degraded state.**  
Not all components of the workload need to be equally reliable. Determining criticality helps you design according to the criticality of each component. You won't overengineer resiliency for components that could slightly deteriorate the user experience, as opposed to components that can cause end-to-end problems if they fail.

The design can be efficient in allocating resources to critical components. You can also implement fault isolation strategies so that if a noncritical component fails or enters a degraded state, it can be isolated to prevent cascading failures.

**Identify potential failure points in the system, especially for the critical components, and determine the effect on user flows.**  
You can analyze the failure cases, blast radius, and intensity of fault: full or partial outage. This analysis influences the design of error handling capabilities at the component level.

**Build self-preservation capabilities by using design patterns correctly and modularizing the design to isolate faults.**
The system will be able to prevent a problem from affecting downstream components. The system will be able to mitigate transient and permanent failures, performance bottlenecks, and other problems that might affect reliability.

You'll also be able to minimize the blast radius.

**Add the capability to scale out the critical components (application and infrastructure) by considering the capacity constraints of services in the supported regions.**  
The workload will be able to handle variable capacity spikes and fluctuations. This capability is crucial when there's an unexpected load on the system, like a surge in valid usage. If the workload is designed to scale out over multiple regions it can even overcome potential temporary resource capacity constraints or other issues impacting in a single region.

**Build redundancy in layers and resiliency on various application tiers.**
Aim for redundancy in physical utilities and immediate data replication. Also aim for redundancy in the functional layer that covers services, operations, and personnel.

Redundancy helps minimize single points of failure. For example, if there’s a component, zonal, or regional outage, redundant deployment (in active-active or active-passive) allows you to meet uptime targets.

Adding intermediaries prevents direct dependency between components and improves buffering. Both of these benefits harden the resiliency of the system.

**Overprovision to immediately mitigate individual failure of redundant instances and to buffer against runaway resource consumption.**
Higher investment in overprovisioning increases resiliency.

The system will continue to operate at full utility during an active failure even before scaling operations can start to remediate the failure. Likewise, you can reduce the risk of unexpected runaway resource consumption claiming your planned buffer, gaining critical triage time, before system faults or aggressive scaling occurs.

***Note:** This will also greatly increase your running costs*

### Design for recovery
|![](/images/goal.svg)|**The workload must be able to anticipate and recover from most failures, of all magnitudes, with minimal disruption to the user experience and business objectives.**|
|---|---|

Even highly resilient systems need *disaster preparedness approaches*, in both architecture design and workload operations. On the data layer, you should have strategies that can repair workload state in case of corruption.

**Have structured, tested, and documented recovery plans that are aligned with the negotiated recovery targets. Plans must cover all components in addition to the system as a whole.**
A well-defined process leads to a quick recovery that can prevent negative impact on the finances and reputation of your business. Conducting regular recovery drills tests the process of recovering system components, data, and failover and failback steps to avoid confusion when time and data integrity are key measures of success.

**Ensure that you can repair data of all stateful components within your recovery targets.**
Backups are essential to getting the system back to a working state by using a trusted recovery point, like the last-known good state.

Immutable and transactionally consistent backups ensure that data can't be altered, and that the restored data isn't corrupted.

**Implement automated self-healing capabilities in the design.**
This automation reduces risks from external factors, like human intervention, and shortens the break-fix cycle.

**Replace stateless components with immutable ephemeral units.**
Building ephemeral units that you can spin up and destroy on demand provides repeatability and consistency. Use side-by-side deployment models to make the transition to the new units incremental, minimizing disruptions.

### Design for operations
|![](/images/goal.svg)|**Shift left in operations to anticipate failure conditions.**|
|---|---|

Test failures early and often in the development lifecycle, and determine the impact of performance on reliability. For the sake of root cause analysis and postmortems, you need to have shared visibility, across teams, of dependency status and ongoing failures. Insights, diagnostics, and alerts from observable systems are fundamental to effective incident management and continuous improvement.

**Build observable systems that can correlate telemetry.**  
Monitoring and diagnostics are crucial operations. If something fails, you need to know that it failed, when it failed, and why it failed. Observability at the component level is fundamental, but aggregated observability of components and correlated user flows provides a holistic view of health status. This data is required to enable site-reliability engineers to prioritize their efforts for remediation.

**Predict potential malfunctions and anomalous behavior.**  
Make active reliability failures visible by using prioritized and actionable alerts.  
Invest in reliable processes and infrastructure that leads to quicker triage.

Site reliability engineers can be notified immediately so that they can mitigate ongoing live site incidents and proactively mitigate potential failures identified by predictive alerts before they become live incidents.

**Simulate failures and run tests in production and pre-production environments.**  
It's beneficial to experience failures in production so you can set realistic expectations for recovery. This allows you to make design choices that gracefully respond to failures. Also, it enables you to test the thresholds you set for business metrics.

**Build components with automation in mind, and automate as much as you can.**  
Automation minimizes the potential for human error, bringing consistency to testing, deployment, and operations.

**Factor in routine operations and their impact on the stability of the system.**  
The workload might be subject to ongoing operations, like application revisions, security and compliance audits, component upgrades, and backup processes. Scrutinizing those changes ensures the stability of the system.

**Continuously learn from incidents in production.**  
Based on the incidents, you can determine the impact and oversights in design and operations that might go unnoticed in preproduction. Ultimately, you'll be able to drive improvements based on real-life incidents.

### Keep it simple
|![](/images/goal.svg)|**Avoid overengineering the architecture design, application code, and operations.**|
|---|---|
It's often what you remove rather than what you add that leads to the most reliable solutions. Simplicity reduces the surface area for control, minimizing inefficiencies and potential misconfigurations or unexpected interactions. On the other hand, oversimplification can introduce single points of failure. Maintain a balanced approach.

**Add components to your architecture only if they help you achieve target business values. Keep the critical path lean.**  
Designing for business requirements can lead to a straightforward solution that's easy to implement and manage. Avoid having too many critical components, because each one is a significant point of failure.

**Establish standards in code implementation, deployment, and processes, and document them.**  
Identify opportunities to enforce those standards by using automated validations.	

Standards provide consistency and minimize human errors. Approaches like standard naming conventions and code style guides can help you maintain quality and make assets easy to identify during troubleshooting.

**Evaluate whether theoretical approaches translate to pragmatic design that applies to your use cases.**  
Application code that's too granular can lead to unnecessary interdependence, extra operations, and difficult maintenance.

**Develop just enough code.**
You'll be able to prevent problems that are the result of inefficient implementations, like unexpected resource consumption, user or dataflow failures, and code bugs.

Conversely, reliability problems should lead to code reviews to ensure that code is resilient enough to handle the problems.

**Take advantage of platform-provided features.**  
This approach minimizes development time. It also enables you to rely on tried and tested practices that have been used with similar workloads.