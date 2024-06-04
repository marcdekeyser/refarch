# Zero Trust
## Guiding principles of Zero Trust
* Verify explicitly - Always authenticate and authorize based on all available data points.
* Use least privilege access - Limit user access with Just-In-Time and Just-Enough-Access (JIT/JEA), risk-based adaptive policies, and data protection.
* Assume breach - Minimize blast radius and segment access. Verify end-to-end encryption and use analytics to get visibility, drive threat detection, and improve defenses.

[references](references.md#zero-trust)

## Zero Trust Architecture
A Zero Trust approach extends throughout the entire digital estate and serves as an integrated security philosophy and end-to-end strategy.  
* Security policy enforcement is at the center of a Zero Trust architecture. This includes Multi Factor authentication with conditional access that takes into account user account risk, device status, and other criteria and policies that you set.
* Identities, devices (also called endpoints), data, applications, network, and other infrastructure components are all configured with appropriate security. Policies that are configured for each of these components are coordinated with your overall Zero Trust strategy. For example, device policies determine the criteria for healthy devices and conditional access policies require healthy devices for access to specific apps and data.
* Threat protection and intelligence monitors the environment, surfaces current risks, and takes automated action to remediate attacks.

## Building apps using zero Trust principles
Zero Trust is a security framework that does not rely on the implicit trust afforded to interactions behind a secure network perimeter. Instead, it uses the principles of explicit verification, least privileged access, and assuming breach to keep users and data secure while allowing for common scenarios like access to applications from outside the network perimeter.

As a developer, it is essential that you use Zero Trust principles to keep users safe and data secure. App developers can improve app security, minimize the impact of breaches, and ensure that their applications meet their customers' security requirements by adopting Zero Trust principles.

[references](references.md#devop-apps-using-zero-trust-principles)