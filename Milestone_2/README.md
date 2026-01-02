# Modifications to C4 Model & Quality Scenarios

### EnrollmentSystem - Architecture Extensions & Justifications

This document describes **quality requirement scenarios** and the corresponding **architectural reasoning** based on the provided **C4 architecture** of the Enrollment System.

---

## Selected Quality Dimensions

1. **Modifiability (Design-time)**
2. **Performance (Run-time)**
3. **Reliability (Run-time)**

---

# Scenario 0 - Modifiability (Design-time)

## Frontend Replacement Without Backend Changes

### Quality Dimension

Modifiability

### Scenario Description

| Element | Description |
| --- | --- |
| **Stimulus** | A UI team replaces **100% of the Enrollment frontend** by implementing a new client (new UI framework + new interaction design) that still supports the same **4 user flows**: (1) browse tickets, (2) enroll, (3) cancel enrollment, (4) join/leave waiting list. |
| **Source** | Product owner / frontend development team. |
| **Environment** | Design-time; backend containers are in **feature freeze** (no functional changes allowed); backend API specifications are published; automated API contract tests exist; staging environment available. |
| **Artifact** | **Presenter-side artifacts only**: `Enrollment Presenter` container and its UI components/controllers (notably `courseTicketController` and `waitingListController`). |
| **Response** | New frontend integrates using the existing backend API contracts; **no backend container requires modification** (`Enrollment Manager`, `Conditions Manager`, `Notification Service`, and their databases). |
| **Response Measure** | **0 backend production code changes**; **0 backend DB schema changes**; **100% backend API contract tests pass**; end-to-end acceptance suite for the 4 enrollment flows passes in staging with **≥99% success rate**. |

### Existing Architecture Support

**Strengths:**

- The C4 model separates the UI into **Presenter containers** and the business logic into backend service containers.
- The frontend communicates with backend services via stable API boundaries, enabling independent frontend evolution.

**Weaknesses:**

- None identified for this scenario as long as API contracts remain stable.

### Required Architectural Extensions

**None.**

**What was added:**

- **No new C4 elements**. (This scenario is satisfied by the existing separation of concerns.)

### Reasoning

The C4 architecture already follows a **client-server / layered architectural style**.  
Because the frontend is isolated in the `Enrollment Presenter` container and depends only on backend API contracts, it can be replaced without changing backend containers or persistence.

---

# Scenario 1 - Performance (Run-time)

## Peak Enrollment Load at Opening Time

### Quality Dimension

Performance

### Scenario Description

| Element | Description |
| --- | --- |
| **Stimulus** | At 08:00, **2,500 students** submit enrollment requests within a **10-minute window** for a small set of popular courses. |
| **Source** | External users (students). |
| **Environment** | Very high load; enrollment window open; database available; SSO operational. |
| **Artifact** | End-to-end path affected by the load: `Enrollment Presenter` (`courseTicketController`) and `Enrollment Manager` (`enrollmentAPI`, `ticketCapacityHandler`, `ticketStoreAdapter`, `enrollmentWriter`). |
| **Response** | Requests are processed without oversubscription and with acceptable response times. |
| **Response Measure** | ≥ **95%** of requests complete in **≤2.5 seconds**; **99.9% correctness** of capacity constraints (no over-enrollment). |

### Existing Architecture Support

**Strengths:**

- `ticketCapacityHandler` enforces capacity correctness (prevents over-enrollment).

**Weaknesses:**

- `ticketStoreAdapter` / DB reads are repeated for the same ticket data during spikes.
- No explicit monitoring to verify latency/throughput targets.

### Required Architectural Extensions

#### **1. New Component: `ticketCache` (in Enrollment Manager)**

- Caches ticket metadata and capacity.
- Used by `enrollmentAPI` and `ticketCapacityHandler` to reduce repeated DB reads.

#### **2. New Container: `Monitoring & Metrics`**

- Collects latency, throughput, and error metrics.
- Enables verification of the **2.5s** and correctness targets.

**What was added:**

- `ticketCache` (component, Enrollment Manager)
- `Monitoring & Metrics` (container)

---

# Scenario 2 - Performance (Run-time)

## Mass Evaluation of Enrollment Conditions

### Quality Dimension

Performance

### Scenario Description

| Element | Description |
| --- | --- |
| **Stimulus** | **600 students** attempt to enroll into the same course within **5 minutes**, triggering repeated condition checks with identical condition schema versions. |
| **Source** | External users (students). |
| **Environment** | Peak load; database available; Conditions checking logic operational. |
| **Artifact** | Condition-evaluation subsystem affected by the stimulus: `conditionReader`, `conditionEvaluator`, `predicateLibrary`, and the `conditionSchema` store (Condition Schema DB), plus the caller path from `Enrollment Manager` (`enrollmentAPI`). |
| **Response** | Eligibility is determined efficiently without repeating expensive evaluations for identical inputs. |
| **Response Measure** | Condition evaluation adds **≤300 ms** to enrollment latency; system handles **≥120 condition-check requests/sec**; eligibility cache hit rate **≥70%** during the 5-minute window. |

### Existing Architecture Support

**Strengths:**

- Separation of responsibilities between enrollment logic and condition management/checking logic.

**Weaknesses:**

- Identical eligibility checks are recomputed repeatedly during spikes.
- Repeated heavy reads of the same condition schema/version.

### Required Architectural Extensions

#### **1. New Component: `eligibilityCache` (in Enrollment Manager)**

- Stores results such as: “Student X eligible for Course Y under Conditions Schema Version Z”.
- Avoids repeated evaluation work for identical inputs.

**What was added:**

- `eligibilityCache` (component, Enrollment Manager)

---

# Scenario 3 - Reliability (Run-time)

## Notification Service Outage During Enrollment

### Quality Dimension

Reliability

### Scenario Description

| Element | Description |
| --- | --- |
| **Stimulus** | `Notification Service` becomes unavailable for **20 minutes** while enrollments and waiting-list auto-enrollments continue. |
| **Source** | Internal infrastructure failure. |
| **Environment** | Enrollment ongoing; `auto-EnrollWorker` processing active; Notification Service down; database and message bus available. |
| **Artifact** | Enrollment-to-notification delivery path: `Enrollment Manager` writers (including `enrollmentWriter` and `auto-EnrollWorker`), the `notificationOutbox`, the `Message Bus / Event Broker`, and the `Notification Service` container. |
| **Response** | Enrollment continues; notifications are delayed but never lost; delivery resumes after recovery. |
| **Response Measure** | **0 lost notifications**; **100% delivered** within **30 minutes** after service recovery; **0 enrollment failures** attributable to the outage. |

### Existing Architecture Support

**Weaknesses:**

- Synchronous calls to Notification Service would block enrollment workflows during outages.
- Without durable buffering, notification events could be lost on failures.

### Required Architectural Extensions

#### **1. New Container: `Message Bus / Event Broker`**

- `Enrollment Manager` publishes events (e.g., `EnrollmentCreated`, `AutoEnrolledFromWaitingList`).
- `Notification Service` consumes events asynchronously.

#### **2. New Component: `notificationOutbox` (in Enrollment Manager)**

- Durable storage of notification events (Outbox Pattern).
- Guarantees events are published even if the service crashes mid-flow.

**What was added:**

- `Message Bus / Event Broker` (container)
- `notificationOutbox` (component, Enrollment Manager)

---

# Scenario 4 - Reliability (Run-time)

## Crash During Auto-Enrollment From Waiting List

### Quality Dimension

Reliability

### Scenario Description

| Element | Description |
| --- | --- |
| **Stimulus** | `auto-EnrollWorker` crashes while processing **1 waiting-list promotion** during the sequence: capacity reservation => enrollment DB write => schedule update. |
| **Source** | Internal system failure. |
| **Environment** | Partial Enrollment Manager failure; relational DB available; crash occurs at an arbitrary point in the sequence. |
| **Artifact** | Waiting-list and enrollment write path: `waitQueueService`, `ticketCapacityHandler`, `enrollmentWriter`, `scheduleWriter`, and the enrollment persistence layer used by these components. |
| **Response** | After restart, the system reaches a safe, consistent state with no partial enrollment effects. |
| **Response Measure** | After recovery, the student ends in **exactly one** of two valid states: (1) still in waiting queue OR (2) enrolled **exactly once**; **0 duplicate enrollments** in **100%** of automated crash-recovery tests. |

### Existing Architecture Support

**Weaknesses:**

- The sequence involves multiple operations; a crash between steps can leave partial state if not grouped properly.

### Architectural Extension Options

#### **No structural extension (DB-level guarantee only)**

- Document and enforce that all auto-enrollment operations execute inside **one ACID DB transaction**.
- If a crash occurs, the DB rolls back and the student remains safely in the queue.
- Idempotency ensured by DB constraints.

**What was added:**

- **No new C4 elements**; only an explicit architectural constraint: _single ACID transaction boundary for auto-enrollment_.

---
