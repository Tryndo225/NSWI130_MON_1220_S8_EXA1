# Modifications to C4 Model & Quality Scenarios
### EnrollmentSystem - Architecture Extensions & Justifications

---

## Selected Quality Dimensions
1. **Performance / Scalability**  
2. **Availability / Reliability**

---

# Scenario 1 - Performance  
## Peak Enrollment Load at Opening Time

### Quality Dimension
Performance / Scalability

### Scenario Description
| Element | Description |
|--------|-------------|
| **Stimulus** | At 08:00, more than **2000 students** attempt enrollment into a few popular classes simultaneously. |
| **Environment** | Very high load, SIS & SSO *(Single Sign-On)* operational. |
| **Artifact** | `Enrollment Presenter`, `courseTicketController`, `Enrollment Manager` (`enrollmentAPI`, `ticketCapacityHandler`, `enrollmentWriter`). |
| **Response** | All requests processed without oversubscription, users get results quickly. |
| **Response Measure** | 95% completed in **≤2 seconds**, 99.9% correctness of capacity (no over-enrollment). |

### Existing Architecture Support
Strengths:
- `ticketCapacityHandler` guarantees correctness through locking.

Weaknesses:
- No caching, which leads to many duplicate DB reads.  
- No monitoring of latency or throughput.  

### Required Architectural Extensions
#### **1. New Component: `ticketCache` (in Enrollment Manager)**
- Caches ticket metadata & capacity.
- Used by `enrollmentAPI` and `ticketCapacityHandler`.

#### **2. New Container: `Monitoring & Metrics`**
- Receives metrics (latency, load, errors).
- Allows target verification (2s limit).


---

# Scenario 2 - Performance  
## Mass Evaluation of Enrollment Conditions

### Quality Dimension
Performance / Scalability

### Scenario Description
| Element | Description |
|--------|-------------|
| **Stimulus** | 500+ students attempt to enroll in a course with **complex enrollment conditions** at the same time. |
| **Environment** | Normal DB availability, peak query load. |
| **Artifact** | `conditionReader`, `conditionEvaluator`, `predicateLibrary`, `conditionSchema`. |
| **Response** | Fast determination of eligibility. |
| **Response Measure** | Conditions evaluation adds **≤200 ms** latency, system handles **100 condition-check requests/sec**. |

### Existing Architecture Support
Strengths:
- Modular separation between Conditions Manager and Enrollment Manager.

Weaknesses:
- No caching of eligibility.  
- Repeated heavy DB queries.

### Required Architectural Extensions
#### **1. New Component: `eligibilityCache` (in Enrollment Manager)**
- Stores temporary results such as “Student X eligible for Course Y under Conditions Z”.

---

# Scenario 3 - Availability  
## Notification Service Outage During Enrollment

### Quality Dimension
Availability / Fault Tolerance

### Scenario Description
| Element | Description |
|--------|-------------|
| **Stimulus** | Notification Service becomes unavailable for **30 minutes**. |
| **Environment** | Enrollment ongoing, waiting-list auto-enrollments still executing. |
| **Artifact** | `auto-EnrollWorker`, `waitQueueService`, `Enrollment Manager` writers, external Notification Service. |
| **Response** | Enrollment continues, notifications are delayed but **never lost**. |
| **Response Measure** | 0 lost notifications, all queued and delivered within 1 hour after recovery. |

### Existing Architecture Support
Weaknesses:
- If Enrollment Manager calls Notification Service synchronously, a crash/outage breaks workflows.
- No buffering for pending notifications.

### Required Architectural Extensions
#### **1. New Container: `Message Bus / Event Broker`**
- Enrollment Manager publishes events like `EnrollmentCreated`, `AutoEnrolledFromWaitingList`.
- Notification Service consumes these events asynchronously.

#### **2. New Component: `notificationOutbox` (in Enrollment Manager)**
- Guarantees durable queuing of notifications.
- Outbox pattern ensures **no lost messages**.

---

#  Scenario 4 - Reliability  
## Crash During Auto-Enrollment From Waiting List

### Quality Dimension
Reliability / Consistency

### Scenario Description
| Element | Description |
|--------|-------------|
| **Stimulus** | `auto-EnrollWorker` crashes during the steps: capacity reservation, DB write, or schedule update. |
| **Environment** | Partial Enrollment Manager failure, DB may or may not have committed. |
| **Artifact** | `waitQueueService`, `ticketCapacityHandler`, `enrollmentWriter`, `scheduleWriter`. |
| **Response** | Final system state must be safe and consistent: no double enrollments, no lost seats, no “removed from queue but not enrolled” states. |
| **Response Measure** | After recovery: system ends up in exactly **one** of two valid states: (1) student still in waiting queue OR (2) student enrolled exactly once. |

### Existing Architecture Support
Weaknesses:
- These steps currently appear to execute as **separate** DB operations.
- Crash between steps can leave the system in an inconsistent, half-updated state (e.g., capacity reserved but enrollment not written).
- There is no mechanism to automatically retry or roll back incomplete operations.

### Architectural Extension Options
#### **No structural extension (Only changes in DB behavior)**
- Document that all auto-enrollment operations run inside **one ACID DB transaction**.
- If crash occurs => DB rolls back => student remains safely in queue.
- Idempotency guaranteed by DB constraints.

- **“One ACID DB transaction”**  
  Grouping multiple DB operations into a **single database transaction** that obeys the ACID properties:
  - **Atomicity** - all operations succeed or none do (no partial state).
  - **Consistency** - transaction moves the DB from one valid state to another valid state.
  - **Isolation** - concurrent transactions don’t interfere in a way that breaks correctness.
  - **Durability** - once committed, the result survives crashes.

  Example in EnrollmentSystem:  
  - Reserve capacity for a ticket  
  - Insert enrollment row  
  - Update student’s timetable  

  If wrapped into one ACID transaction, either *all three* persist, or *none* persist if something fails.

---