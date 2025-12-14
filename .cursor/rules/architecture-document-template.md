# [System Name] Architecture

> **Version:** 1.0
> **Date:** [YYYY-MM-DD]
> **Author:** [Name/Team]
> **Scope:** [One sentence - what this architecture covers]

## 1. Context & Scope

**System Purpose:** [What problem does this solve?]

**Stakeholders:** [Who uses/cares about this system?]

**Context Diagram:**

```
[Show system boundary and external dependencies]
External System A ──> [Your System] <──> External System B
                           │
                           v
                      Database / Storage
```

## 2. Quality Attributes (Architectural Drivers)

**Performance:**
- Response time: <100ms for 95th percentile
- Throughput: 10,000 requests/second

**Scalability:**
- Support 100K concurrent users
- Horizontal scaling via load balancer

**Availability:**
- 99.9% uptime (max 8.76 hours downtime/year)
- Graceful degradation when dependencies fail

**Security:**
- HTTPS/TLS 1.3 for all communication
- OAuth2 authentication
- Data encrypted at rest (AES-256)

**Constraints:**
- Must run on AWS infrastructure
- Maximum response time 500ms (SLA requirement)
- Budget: $5K/month operational cost

## 3. Architectural Views

### 3.1 Logical View (System Structure)

**Layered Architecture:**

```
┌─────────────────────────────┐
│     Presentation Layer      │  (API, Web UI)
├─────────────────────────────┤
│    Business Logic Layer     │  (Services, Domain Logic)
├─────────────────────────────┤
│     Data Access Layer       │  (Repositories, ORM)
└─────────────────────────────┘
         │
         v
    [Database]
```

**Component Diagram:**

```
[API Gateway] ──> [Order Service] ──> [Order DB]
      │               │
      │               v
      │          [Event Bus]
      │               │
      v               v
[Auth Service]   [Inventory Service] ──> [Inventory DB]
      │               │
      v               v
 [User DB]       [Payment Service] ──> [Payment Gateway]
```

### 3.2 Process View (Runtime Behavior)

**State Machine: Order Processing**

```
[Created] ──validate──> [Validated] ──reserve──> [Reserved] ──pay──> [Paid] ──ship──> [Shipped]
    │                       │                        │                  │
    │──error──> [Failed]    │──timeout──> [Expired]  │──cancel──> [Cancelled]
    │                       │                        │                  │
    └───────────────────────┴────────────────────────┴──────────────────┘
                                      retry
```

**Sequence Diagram: Place Order**

```
Client    API Gateway    Order Service    Inventory    Payment    Event Bus
  │────POST────>│             │                │            │           │
  │             │──validate──>│                │            │           │
  │             │             │──check_stock──>│            │           │
  │             │             │<──available────│            │           │
  │             │             │──────charge────────────────>│           │
  │             │             │<──────success───────────────│           │
  │             │             │──publish───────────────────────────────>│
  │             │<──200 OK────│                │            │           │
  │<──response──│             │                │            │           │
```

### 3.3 Data View

**Data Flow:**

```
User Input → Validation → Business Logic → Data Layer → Database
                                  │
                                  └──> Cache (Redis)
                                  │
                                  └──> Event Bus (Async processing)
```

**Key Data Models:**

```python
class Order:
    order_id: str
    customer_id: str
    items: list[OrderItem]
    status: OrderStatus
    total_amount: Decimal
    created_at: datetime
```

### 3.4 Deployment View

**Physical Topology:**

```
           [Load Balancer]
               │
    ┌──────────┼──────────┐
    v          v          v
[App Server 1] [App Server 2] [App Server 3]
    │          │          │
    └──────────┼──────────┘
               v
        [Database Cluster]
         Primary + 2 Replicas
```

**Environment:** AWS, Docker containers, Kubernetes orchestration

## 4. Key Design Decisions

### Decision 1: Event-Driven Architecture for Order Processing

**Context:** Orders require coordination between inventory, payment, and shipping services.

**Decision:** Use event-driven architecture with message queue (RabbitMQ).

**Rationale:** Decouples services, enables async processing, improves scalability.

**Alternatives:**
- Synchronous API calls: Creates tight coupling, single point of failure
- Database polling: High latency, resource intensive

**Consequences:**
- ✅ Gained: Loose coupling, fault isolation, horizontal scalability
- ❌ Cost: Eventual consistency, debugging complexity, message queue dependency

### Decision 2: CQRS Pattern for Reporting

**Context:** Read-heavy reporting queries slow down write operations.

**Decision:** Separate read and write models using CQRS pattern.

**Rationale:** Optimize read and write paths independently.

**Alternatives:**
- Single database: Read queries block writes
- Database replication: Still uses same schema, complex queries still slow

**Consequences:**
- ✅ Gained: Optimized read models, fast queries, scalable reads independently
- ❌ Cost: Data synchronization lag, increased storage

## 5. Cross-Cutting Concerns

**Error Handling:**
- Fail fast on invalid input (return 400 Bad Request)
- Retry transient failures (network, database timeout) with exponential backoff
- Circuit breaker pattern for external service calls

**Logging:**
- Structured JSON logs (correlation ID for request tracing)
- Log levels: ERROR (always), WARN (suspicious), INFO (key operations), DEBUG (dev only)

**Security:**
- OAuth2 for authentication, JWT tokens (15 min expiry)
- Role-based access control (RBAC)
- Input validation and sanitization at API boundary

**Monitoring:**
- Health check endpoint: `/health`
- Metrics: Response time, error rate, throughput (Prometheus)
- Distributed tracing: OpenTelemetry

## 6. References

- ISO/IEC/IEEE 42010: Systems and Software Engineering - Architecture Description
- [Internal ADR Repository]
- [API Documentation]
