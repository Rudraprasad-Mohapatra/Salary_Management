# Implementation Plan

## 1. Technical Stack

### Backend

```text
Ruby
Ruby on Rails
Rails API
```

Rails responsibilities:

* HTTP request handling
* routing
* controllers
* business/domain models
* validations
* database interaction
* serialization
* error handling

---

### Database

```text
PostgreSQL
```

PostgreSQL will store:

* employees
* departments
* countries
* salary records

The database will enforce important integrity constraints where appropriate.

---

### Frontend

```text
React
TypeScript
```

Responsibilities:

* UI
* routing
* forms
* employee table
* employee details
* salary history
* dashboard
* analytics

---

### Testing

Backend:

```text
RSpec
```

Frontend:

```text
Vitest
React Testing Library
```

Use the existing project testing setup if already established.

---

# 2. High-Level Architecture

```text
                    Browser
                       |
                       |
                       v
                React Application
                       |
                       | HTTP / JSON
                       |
                       v
                Rails Application
                       |
             +---------+---------+
             |                   |
             v                   v
        Domain Logic          Queries
             |                   |
             +---------+---------+
                       |
                       v
                   PostgreSQL
```

The application will initially be a modular monolith.

There is no need for microservices.

---

# 3. Domain Model

The core domain begins with:

```text
Employee
    |
    | has_many
    |
    v
SalaryRecord
```

Potential supporting entities:

```text
Department
Country
```

The exact implementation should be determined after inspecting the existing repository.

---

# 4. Employee Model

Conceptually:

```text
Employee

id
employee_number
first_name
last_name
email
country
department
job_title
employment_type
status
created_at
updated_at
```

Important constraints:

* employee number should be unique
* email should be valid
* required fields should be present
* status should be controlled
* employee should not normally be physically deleted

---

# 5. Salary Record Model

Conceptually:

```text
SalaryRecord

id
employee_id
amount
currency
effective_from
effective_to
created_at
updated_at
```

Relationship:

```text
Employee
  has_many :salary_records

SalaryRecord
  belongs_to :employee
```

Salary history is represented as multiple salary records.

---

# 6. Salary History

Instead of:

```text
Employee
salary = 1000000
```

use:

```text
Employee
   |
   +-- SalaryRecord ₹700,000
   |
   +-- SalaryRecord ₹850,000
   |
   +-- SalaryRecord ₹1,000,000
```

This allows historical salary information to remain available.

---

# 7. Salary Effective Dates

Salary records represent periods of validity.

Example:

```text
₹700,000
effective_from: 2024-01-01
effective_to:   2024-12-31

₹850,000
effective_from: 2025-01-01
effective_to:   2025-12-31

₹1,000,000
effective_from: 2026-01-01
effective_to:   null
```

The final implementation should prevent conflicting active periods.

---

# 8. API Design

API namespace:

```text
/api/v1
```

Employees:

```text
GET    /api/v1/employees
GET    /api/v1/employees/:id
POST   /api/v1/employees
PATCH  /api/v1/employees/:id
```

Salary:

```text
GET  /api/v1/employees/:employee_id/salaries
POST /api/v1/employees/:employee_id/salaries
```

Analytics:

```text
GET /api/v1/salary-insights
```

---

# 9. Employee List API

Example:

```text
GET /api/v1/employees?page=1&per_page=25
```

Filtering:

```text
GET /api/v1/employees?country=India
```

Search:

```text
GET /api/v1/employees?search=Rahul
```

Multiple filters:

```text
GET /api/v1/employees?
    country=India&
    department=Engineering&
    status=active
```

The backend performs filtering.

The frontend should not download all 10,000 employees and filter them in JavaScript.

---

# 10. Salary Insights API

Example:

```text
GET /api/v1/salary-insights?currency=INR
```

Possible response:

```json
{
  "currency": "INR",
  "employee_count": 3500,
  "average_salary": 1240000,
  "median_salary": 1100000,
  "minimum_salary": 300000,
  "maximum_salary": 8500000
}
```

Additional dimensions:

```text
country
department
job_title
```

The exact response shape should be kept simple and driven by actual frontend needs.

---

# 11. Rails Application Structure

Expected Rails structure:

```text
app/
├── controllers/
├── models/
├── services/
├── queries/
└── serializers/
```

Do not create all directories/classes immediately.

Introduce abstractions only when they provide value.

For example:

If analytics logic becomes complex:

```text
SalaryInsightsQuery
```

may be appropriate.

But don't create:

```text
EmployeeManagerService
EmployeeRepository
EmployeeFactory
EmployeeCoordinator
```

without a real need.

Rails already provides useful conventions.

---

# 12. Rails Learning Objectives

During implementation, understand:

### Ruby

* classes
* modules
* methods
* blocks
* symbols
* hashes
* arrays
* keyword arguments
* exceptions

### Rails

* MVC
* routes
* controllers
* models
* Active Record
* migrations
* validations
* associations
* scopes
* callbacks
* serializers
* database queries
* transactions
* seeds
* environment configuration

### RSpec

* describe
* context
* it
* let
* subject
* factories
* expectations
* request specs
* model specs

---

# 13. Frontend Architecture

Suggested structure:

```text
src/
├── components/
├── pages/
├── layouts/
├── services/
├── hooks/
├── types/
└── utils/
```

Possible pages:

```text
/dashboard
/employees
/employees/:id
```

Components should remain focused.

---

# 14. Dashboard

Dashboard responsibilities:

```text
Employee count
Salary statistics
Salary distribution
Country breakdown
Department breakdown
```

Filters:

```text
Country
Department
Job title
Currency
```

The dashboard consumes the Rails analytics API.

---

# 15. Employee Page

The employee table should provide:

```text
Employee ID
Name
Email
Country
Department
Job Title
Status
Current Salary
```

Features:

```text
Search
Filtering
Pagination
Open employee
```

---

# 16. Employee Detail

Display:

```text
Employee Information

Current Salary

Salary History

Salary Timeline
```

HR should be able to add a new salary record.

---

# 17. Database Indexing

Consider indexes for:

```text
employee_number
email
country
department
status
salary_record.employee_id
salary_record.effective_from
salary_record.currency
```

Only add indexes that support actual queries.

---

# 18. Seed Strategy

The seed process should create:

```text
10,000 employees
```

with realistic variation.

For example:

```text
Countries:
India
USA
UK
Germany
Singapore
Australia
Canada

Departments:
Engineering
Product
Sales
Finance
HR
Marketing
Operations
```

Generate:

* employee IDs
* names
* emails
* departments
* countries
* job titles
* employment status
* currencies
* salary histories

Seed generation should be deterministic where practical.

---

# 19. Testing Strategy

Test the domain first.

Then APIs.

Then frontend behavior.

Priority:

```text
Domain
  ↓
API
  ↓
UI
```

Core domain tests:

```text
Employee validations
Salary validations
Salary periods
Salary history
Analytics calculations
```

API tests:

```text
Employee endpoints
Salary endpoints
Analytics endpoint
```

Frontend tests:

```text
Employee table
Search
Pagination
Dashboard
```

---

# 20. Performance Strategy

For 10,000 employees:

```text
Database filtering
Database indexes
Pagination
Efficient queries
Avoid N+1 queries
```

Do not introduce distributed infrastructure.

Performance should be measured where useful rather than assumed.

---

# 21. Deployment

Deployment architecture:

```text
Internet
   |
   v
Frontend
   |
   v
Rails API
   |
   v
PostgreSQL
```

Production secrets must come from environment variables.

Never commit:

```text
DATABASE_PASSWORD
SECRET_KEY
API_KEYS
```

---

# 22. Documentation

Maintain:

```text
docs/
├── requirements.md
├── implementation.md
├── architecture.md
├── decisions.md
├── assumptions.md
├── performance.md
└── ai-development-log.md
```

README should explain how to run the complete application.

---

# 23. Development Principle

Every implementation phase follows:

```text
Understand
    ↓
Design
    ↓
Implement
    ↓
Test
    ↓
Review
    ↓
Commit
```

Do not implement multiple unrelated phases before committing.

---

# 24. Definition of Done

The application is complete when:

* backend works
* frontend works
* database works
* 10,000 employees can be seeded
* employee CRUD works
* salary history works
* analytics work
* search works
* filtering works
* pagination works
* tests pass
* production deployment works
* documentation is complete
* Git history shows incremental development
* AI usage is documented
