## 6. OPDG Governance and Administration Process

This chapter outlines the operational governance and administrative processes for managing the Microsoft On-premises Data Gateway (OPDG) at Elections Canada (EC). The governance structure ensures that all usage aligns with EC’s security and operational policies, provides visibility over gateway configurations, and introduces a formal request and approval process managed by the Power Platform Centre of Excellence (PPCoE).

---

### 6.1 Governance Roles and Responsibilities

| Role                        | Responsibility |
|----------------------------|----------------|
| **Power Platform CoE**     | Owns OPDG policy, approves project intake, manages gateway configuration and DLP rules |
| **Tenant Administrators**  | Implement approved connections and monitor operational health in the Admin Center |
| **IT Operations (Ops)**    | Maintain underlying infrastructure (VMs, networking), and act on incidents via RFS process |
| **Project Teams**          | Submit OPDG usage requests and support onboarding with functional and technical input |

---

### 6.2 Project Intake Workflow

All project teams requiring access to on-premises APIs or data sources via the OPDG must follow this structured process managed by the CoE.

#### Intake Steps:

1. **Submit Request via CoE App**
   - Include details such as target systems, authentication model, frequency, environments, and purpose.
2. **Review by PPCoE**
   - Assess DLP policy, security scope, service principal requirements, and system readiness.
3. **Service Principal Issuance**
   - App registration and service principal created by the tenant admin team.
4. **Connector Creation and Access Setup**
   - Tenant admin deploys gateway connection, restricts via DLP and RBAC, and confirms availability to the project team.

#### Mermaid Diagram: OPDG Intake Flow

```mermaid
graph TD
  A[Project Team Request in CoE App] --> B[PPCoE Review]
  B --> C{Approved?}
  C -- No --> D[Reject or Request Clarification]
  C -- Yes --> E[App Registration & Service Principal Created]
  E --> F[Gateway Connection Configured]
  F --> G[DLP and RBAC Applied]
  G --> H[Access Granted to Project Team]
````

---

### 6.3 Use of EC RFS Process for Infrastructure Dependencies

The OPDG depends on stable, secure on-premises infrastructure at the EDC Gatineau datacenter. Scenarios requiring intervention on this infrastructure are managed via EC’s existing **RFS (Request for Service)** process.

#### Trigger Scenarios for RFS Submission

| Scenario                                 | Description                                                                              |
| ---------------------------------------- | ---------------------------------------------------------------------------------------- |
| **Firewall Rule Changes**          | New API integrations often require updates to firewall outbound rules or NAT exceptions. |
| **Network Routing Issues**         | If gateway VM cannot reach on-prem targets due to subnet, route, or DNS issues.          |
| **Gateway VM Patching/Restart**    | Scheduled or unscheduled restarts/patches coordinated by SSC and EC IT Ops.              |
| **Performance or Capacity Issues** | VM CPU/RAM issues, disk IO bottlenecks, or node failure.                                 |
| **Infrastructure Migration**       | Gateway VM needs to be moved due to hypervisor, cluster, or storage changes.             |

In all cases, the CoE or Tenant Admin team will **initiate an RFS** ticket through EC ITSM tools and coordinate approval and implementation with SSC and EC Infrastructure leads.

### 6.4 Auditing and Monitoring

All gateway activities are monitored through:

* **Microsoft Purview**: For compliance and audit tracking.
* **Power Platform Admin Center**: To view real-time gateway status, logs, and performance metrics.
* **RFS Ticketing System**: For tracking infrastructure incidents and their resolution steps.

---

### 6.5 Decommissioning and Offboarding

When a project no longer requires access to on-premises systems via OPDG:

1. Submit a decommissioning request via the CoE intake app.
2. PPCoE deletes connectors and revokes service principals.
3. DLP and RBAC rules are updated to remove access.
4. Logs are archived as per EC retention policies.

---

### 6.6 Summary

The OPDG Governance and Administration process ensures:

* Secure, controlled, and auditable access to on-premises systems.
* Clear accountability via PPCoE and Tenant Admin oversight.
* Integration with existing EC RFS processes for infrastructure operations.
* A structured intake and decommissioning workflow to manage project lifecycle needs.

This framework adheres to Microsoft best practices for hybrid cloud integration and aligns with Elections Canada’s broader digital transformation roadmap.