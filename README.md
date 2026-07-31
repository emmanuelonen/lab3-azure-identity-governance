# Lab 3 — Azure Identity & Access Management
### Zero Trust Identity Governance · Entra ID · RBAC · Managed Identities · Conditional Access · PIM

| Field | Value |
|---|---|
| **Completed** | July 2026 |
| **Platform** | Microsoft Entra Admin Centre · Azure Portal · Azure Cloud Shell · PowerShell (Microsoft Graph SDK) |
| **Cost** | $0 — Azure Free Account + Microsoft Entra ID P2 Free Trial (30 days) |
| **Time taken** | 2–3 hours across multiple sessions |
| **Cert alignment** | CompTIA Security+ · SC-300 Identity & Access Administrator · AZ-104 · AZ-500 |
| **Career relevance** | Cloud Engineer · Identity Administrator · Security Analyst · DevSecOps Engineer |

---

## The Business Problem This Lab Solves

Every organisation using Microsoft cloud services must answer one fundamental question: **who has access to what, and how is that controlled at scale?**

Identity is the new security perimeter. Traditional network-based security models assume trust based on location — if you're inside the network, you're trusted. Zero Trust inverts this entirely: **never trust, always verify** — regardless of where the request originates.

In this lab, **FinSecure Corp** — a financial services organisation migrating core workloads to Azure — must deliver a compliant identity governance architecture under three regulatory frameworks simultaneously:

- **ISO/IEC 27001** — information security management
- **PCI-DSS** — payment card industry data security
- **SOC 2 Type II** — security, availability and confidentiality

The requirements are non-negotiable in regulated industries:

- Centralised identity management with zero manual overhead
- Least-privilege access enforced at every resource boundary
- MFA enforced for all users with no exceptions
- Legacy authentication protocols completely blocked
- Privileged roles available only on demand, never permanently assigned
- Service-to-service authentication with no stored credentials anywhere in code

This is the exact identity architecture a Cloud Engineer or Identity Administrator implements on day one of any enterprise Azure engagement in financial services, healthcare or government.

| Role | How this lab applies |
|---|---|
| **Cloud Engineer** | Designing identity governance, implementing RBAC, configuring managed identities |
| **Security Analyst** | Monitoring sign-in and audit logs, enforcing Conditional Access, reviewing identity posture |
| **Identity Administrator** | Managing user lifecycles, Entra ID roles and governance at scale |
| **DevOps Engineer** | Automating identity provisioning with Microsoft Graph SDK and eliminating hardcoded credentials |

---

## Identity Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│              MICROSOFT ENTRA ID TENANT                                  │
│              (finsecure.onmicrosoft.com)                                │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  IDENTITY GOVERNANCE                                             │   │
│  │  [Users & Groups] ──► [Dynamic Rules: (department -eq "IT")]    │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  ACCESS CONTROL (RBAC)                                           │   │
│  │  [Built-in Roles] ──► [Custom: VM Operator] ──► [Scoped Assign] │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  CONDITIONAL ACCESS (Zero Trust)                                 │   │
│  │  [CA001: Require MFA] ──► [CA002: Block Legacy] ──► [CA003: MDM]│   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  PRIVILEGED IDENTITY MANAGEMENT (PIM)                            │   │
│  │  [Eligible Assignment] ──► [JIT Request] ──► [1-Hour Time-Bound]│   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  MANAGED IDENTITIES                                              │   │
│  │  [app-identity] ──► [No-Secret Token] ──► [Storage Blob Reader] │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  MONITORING & AUDIT                                              │   │
│  │  [Sign-in Logs] ──► [Audit Logs] ──► [Defender for Cloud CSPM]  │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## What Was Built

- ✅ Microsoft Entra ID P2 trial activated — mandatory prerequisite for Conditional Access and PIM
- ✅ Enterprise user `john.doe@eonenitgmail.onmicrosoft.com` provisioned with department and job title attributes
- ✅ User provisioned via Microsoft Graph PowerShell SDK — programmatic identity creation demonstrated
- ✅ Dynamic Security Group `IT-Staff` created with rule `(user.department -eq "IT")`
- ✅ Dynamic group membership verified — John Doe auto-populated via attribute evaluation
- ✅ Built-in `Reader` role assigned to John Doe at subscription scope via PowerShell
- ✅ Custom RBAC role `Virtual Machine Operator` created with scoped least-privilege permissions (start, restart, deallocate, read only)
- ✅ Conditional Access Policy `CA001` — Require MFA for All Users (Report-only → Enabled)
- ✅ Conditional Access Policy `CA002` — Block Legacy Authentication Protocols
- ✅ Conditional Access Policy `CA003` — Require Intune Compliant Device
- ✅ User-Assigned Managed Identity `app-identity` provisioned in `rg-identity-lab`
- ✅ `Storage Blob Data Reader` RBAC role assigned to `app-identity` principal
- ✅ Managed identity access tested from VM — IMDS OAuth 2.0 token acquired without credentials
- ✅ PIM eligible assignment configured — Global Administrator as eligible (not permanent)
- ✅ PIM role activated with mandatory business justification — 1-hour time-bound window
- ✅ Audit logs verified — PIM activation event confirmed in Directory Audit Logs
- ✅ Managed Identity activity reviewed via storage activity and Entra sign-in logs
- ✅ Microsoft Defender for Cloud identity recommendations reviewed for CSPM posture

---

## Architecture Decisions — Why Each Choice Was Made

| Decision | Rationale | Enterprise Relevance |
|---|---|---|
| **Entra ID P2 over Free tier** | P2 is mandatory for Risk-based Conditional Access, Access Reviews, and PIM. Free tier cannot enforce Zero Trust controls at all. | Every regulated industry Azure deployment requires P2 — know the licence requirement before designing identity controls. |
| **Dynamic group membership over static** | `(user.department -eq "IT")` auto-adds/removes users when attributes change. Zero manual overhead. | At enterprise scale, manual group management is operationally unsustainable and a compliance risk during offboarding. |
| **Custom RBAC role over Contributor** | Contributor grants 100+ permissions. The VM Operator role grants exactly 4: start, restart, deallocate, read. | Least-privilege principle — operators cannot delete, reconfigure network, or modify storage. Reduces blast radius of compromised accounts. |
| **Conditional Access in Report-only first** | Tests policy impact before enforcement prevents accidental lockout of legitimate users. | Change management best practice — required in all regulated environments before enabling policies that could block production access. |
| **Blocking legacy authentication** | POP3, IMAP4, SMTP cannot process modern OAuth 2.0 MFA challenges. Attackers target these endpoints specifically to bypass MFA. | Blocking legacy auth is the single highest-impact Conditional Access control — eliminates an entire class of credential-stuffing attack. |
| **User-assigned over System-assigned Managed Identity** | User-assigned identities are independent resources that can be attached to multiple compute resources. System-assigned identities are tied to a single resource lifecycle. | Distributed application architectures and scaled deployments require identities that outlive individual VM instances. |
| **PIM Eligible over Active assignment** | Eligible assignments mean the Global Administrator role is dormant until explicitly activated with justification. No one has permanent privileged access. | Permanent admin accounts are the primary target of identity attacks. JIT access eliminates the standing privilege that makes them valuable targets. |
| **IMDS token acquisition over stored keys** | `http://169.254.169.254` — the Azure Instance Metadata Service — issues tokens at runtime to the workload. No credentials exist in code, config files, or environment variables. | Eliminates the most common source of cloud credential leaks: hardcoded secrets in repositories. Required for modern secure application architecture. |

---

## Key Concepts Explained

### What is Microsoft Entra ID?

Microsoft Entra ID (formerly Azure Active Directory) is Microsoft's cloud-based identity and access management service. It is the equivalent of Active Directory for cloud environments — but it goes further. Where on-premises AD controls who can log into domain-joined computers, Entra ID controls who can access cloud applications, APIs, Azure resources, Microsoft 365, and third-party SaaS services. Every Microsoft cloud service authenticates through Entra ID.

### What are Dynamic Groups?

Instead of an administrator manually adding users to a group, a dynamic group evaluates a rule against user attributes in real time. The rule `(user.department -eq "IT")` means: any user whose Department attribute equals "IT" is automatically a member. When someone joins IT, their department is set and they instantly inherit all IT access. When they leave IT, their department changes and access is immediately revoked — no ticket required, no manual step, no risk of orphaned access.

### What is Azure RBAC?

Role-Based Access Control is the authorisation system for Azure resources. It answers: what can this identity do to this resource? RBAC uses three components: a security principal (user, group, or managed identity), a role definition (a set of permitted actions), and a scope (which resources the role applies to). The key principle is least privilege — grant only the minimum permissions required for the task, nothing more.

### What is Conditional Access?

Conditional Access is Entra ID's policy engine. It evaluates real-time signals — who is the user, what device are they using, what location are they in, what risk level has been detected — and makes an access decision: allow, block, or allow with conditions (require MFA, require compliant device). It is the enforcement point for Zero Trust: every access request is evaluated regardless of whether it comes from inside or outside the corporate network.

### What is Privileged Identity Management (PIM)?

PIM eliminates permanent privileged access. Instead of a user permanently holding the Global Administrator role (which means their account is always a high-value target), PIM makes the role Eligible. When the user needs administrative access, they activate the role — providing a justification — and hold it for a configured time window (e.g., 1 hour). Every activation is audited. When the window expires, the privilege is automatically removed.

### What is a Managed Identity?

A managed identity is an Entra ID identity automatically managed by Azure on behalf of a resource (such as a VM or function app). Instead of a developer writing code that connects to storage using a connection string or access key — credentials that can be accidentally committed to a repository or leaked — the resource authenticates using its managed identity. Azure handles token issuance, rotation and expiry entirely. The application code contains no credentials of any kind.

---

## Screenshot Evidence Index

| Screenshot | File | What It Proves |
|---|---|---|
| 0a | `0a-Entra-p2-license-active.jpeg` | Microsoft Entra ID P2 Trial activated — 100 licences available |
| 1a | `1a-user-creation-portal.jpeg` | John Doe provisioned with IT department attribute in Entra Admin Centre |
| 1b | `1b-powershell-user-creation.jpeg` | Microsoft Graph SDK user creation — HTTP 400 error validates unique UPN enforcement |
| 1c | `1c-dynamic-group-rule.jpeg` | IT-Staff dynamic group created with `(user.department -eq "IT")` rule |
| 1d | `1d-dynamic-group-membership.jpeg` | John Doe auto-populated in IT-Staff via attribute evaluation |
| 2a | `2a-rbac-reader-assignment.jpeg` | Reader role assigned to John Doe at subscription scope via PowerShell |
| 2b | `2b-custom-role-creation.jpeg` | Virtual Machine Operator custom role deployed with 4 scoped permissions |
| 3a | `3a-ca-compliant-device.jpeg` | CA001 — Require MFA for All Users policy configuration |
| 3b | `3b-ca-block-legacy.jpeg` | CA002 — Block Legacy Authentication Protocols policy |
| 3c | `3c-ca-compliant-device.jpeg` | CA003 — Require Intune Compliant Device policy |
| 4a | `4a-managed-identity-create.jpeg` | app-identity user-assigned managed identity provisioned |
| 4b | `4b-mi-role-assignment.jpeg` | Storage Blob Data Reader role assigned to app-identity principal |
| 4c | `4c-mi-access-test.jpeg` | IMDS OAuth 2.0 token acquired — secretless storage access confirmed |
| 5a | `5a-pim-eligible-assignment.jpeg` | Global Administrator configured as Eligible in PIM |
| 5b | `5b-pim-activation.jpeg` | PIM role activated with business justification — 1-hour time-bound |
| 6a | `6a-audit-log-pim.jpeg` | PIM elevation event confirmed in Directory Audit Logs |
| 6b | `6b-managed-identity-audit.jpeg` | Managed identity activity reviewed — storage activity log |
| 6c | `6c-defender-identity-recommendations.jpeg` | Microsoft Defender for Cloud CSPM identity posture review |

---

## Files in This Repository

| File | Contents |
|---|---|
| `scripts/01-activate-entra-p2.md` | Steps to activate Entra ID P2 trial — portal walkthrough |
| `scripts/02-create-users-graph.ps1` | Microsoft Graph SDK user provisioning |
| `scripts/03-create-dynamic-groups.ps1` | Dynamic security group creation and verification |
| `scripts/04-configure-rbac.ps1` | Built-in role assignment and custom role creation |
| `scripts/05-create-managed-identity.ps1` | Managed identity provisioning, RBAC assignment, token test |
| `scripts/06-configure-pim.md` | PIM eligible assignment and activation walkthrough |
| `verification/verify-lab3.ps1` | Full verification checklist — all identity resources |
| `screenshots/` | 18 sequential evidence screenshots — live execution |
| `docs/Lab3-Azure-Identity-Evidence.pdf` | Combined evidence document with reasoning |

---

## Verification Checklist

| Check | Location / Command | Expected Result |
|---|---|---|
| Entra ID P2 active | Microsoft 365 Admin → Your products | Microsoft Entra ID P2 Trial — Active |
| User exists | Entra Admin → Users | `john.doe@eonenitgmail.onmicrosoft.com` — Enabled |
| Dynamic group exists | Entra Admin → Groups | IT-Staff — Dynamic membership rule active |
| Dynamic membership correct | Groups → IT-Staff → Members | John Doe listed automatically |
| Reader role assigned | Resource group → IAM → Role assignments | john.doe — Reader — Subscription scope |
| Custom role exists | Subscription → IAM → Roles | Virtual Machine Operator — Custom |
| CA001 policy active | Entra → Protection → Conditional Access | CA001-Require-MFA-All-Users — Enabled |
| CA002 policy active | Entra → Protection → Conditional Access | CA002-Block-Legacy-Auth — Enabled |
| CA003 policy active | Entra → Protection → Conditional Access | CA003-Require-Compliant-Device — Enabled |
| Managed identity exists | Managed Identities blade | app-identity — Succeeded |
| MI role assignment | Storage → IAM → Role assignments | app-identity — Storage Blob Data Reader |
| PIM eligible assignment | Entra → PIM → Assignments | Global Administrator — Eligible (not Active) |
| PIM audit log entry | Entra → Monitoring → Audit logs | PIM activation event with justification |
| Defender posture reviewed | Defender for Cloud → Identity recommendations | CSPM recommendations reviewed |

---

## On-Premises to Azure Identity Mapping

| On-Premises Concept | Azure / Entra ID Equivalent | Why It Matters |
|---|---|---|
| Active Directory Domain | Microsoft Entra ID Tenant | Cloud-native identity — no domain controllers to manage |
| AD Security Groups | Entra ID Security Groups | Same concept, cloud-native scale |
| Group Policy (GPO) | Conditional Access Policies | Dynamic, risk-based enforcement vs static configuration |
| Service Accounts (passwords) | Managed Identities | No credentials to store, rotate or leak |
| Domain Admin accounts | PIM Eligible Assignments | Just-in-time access — no standing privilege |
| Windows Event Logs | Entra Sign-in & Audit Logs | Centralised, queryable, compliance-ready |
| Network perimeter (firewall) | Conditional Access (identity perimeter) | Zero Trust — identity is the new boundary |

---

## Lab 1 → Lab 2 → Lab 3 Progression

| Lab 1 — Active Directory | Lab 2 — Azure Networking | Lab 3 — Azure Identity |
|---|---|---|
| Domain Controller = identity authority | VNet = network boundary | Entra ID Tenant = cloud identity authority |
| OU structure = logical grouping | Subnets = network segmentation | Dynamic Groups = automated identity grouping |
| GPO = policy enforcement | NSG rules = traffic policy | Conditional Access = identity-aware policy |
| Domain join = managed asset | Private Endpoint = private resource | Managed Identity = secretless resource auth |
| DSRM = break-glass recovery | GatewaySubnet = hybrid fallback | PIM Eligible = break-glass escalation |
| Help desk password reset | Network Watcher diagnostics | Audit log review and sign-in monitoring |

Every lab builds the same foundational principle: **structure first, access by exception, deny by default, audit everything.**

---

## Interview Questions This Lab Prepares You For

**"What is the difference between Entra ID roles and Azure RBAC roles?"**
Entra ID roles manage access to the directory itself — creating users, managing groups, configuring Conditional Access. Azure RBAC roles manage access to Azure resources — virtual machines, storage, networking. They are separate systems with separate role definitions and separate assignment scopes.

**"How would you implement just-in-time access for administrators?"**
Configure Privileged Identity Management with eligible assignments rather than active assignments. Users activate the role on demand by providing a business justification. The elevation is time-bound (e.g., 1 hour) and every activation creates an immutable audit log entry.

**"What is a managed identity and when would you use it?"**
A managed identity is an Entra ID identity automatically managed by Azure on behalf of a resource. Use it whenever a workload needs to authenticate to another Azure service — storage, Key Vault, databases. It eliminates every credential from application code because Azure handles token issuance entirely.

**"Why should you block legacy authentication?"**
Legacy protocols — POP3, IMAP4, SMTP — cannot process OAuth 2.0 interactive MFA challenges. If legacy authentication is permitted, an attacker with a stolen password can authenticate using these protocols and bypass MFA entirely. Blocking legacy authentication closes this bypass completely.

---

*Part of a structured cloud engineering portfolio — Lab 1: Active Directory | Lab 2: Azure Networking | Lab 3: Azure Identity | Lab 4: KQL & Azure Monitor | Lab 5: Terraform on Azure*

**Emmanuel Onen · Senior Systems Engineer · Cayman Islands**
*Certification path: AZ-900 → AZ-104 → AI-102 → AZ-400*
*GitHub: [github.com/emmanuelonen](https://github.com/emmanuelonen)*
