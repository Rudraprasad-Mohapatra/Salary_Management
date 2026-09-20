# Implementation Plan & Technical Roadmap

## 1. Technical Stack

### Backend
* **Language & Framework**: Ruby 3.3.x on Ruby on Rails 7.2.x (Rails API Mode)
* **Responsibilities**: HTTP routing, controller actions, Active Record domain models, validations, database interactions, JSON serialization, and error handling.

### Database
* **Database Engine**: SQLite3 for local development and test suite execution; PostgreSQL optional for production deployment.
* **Storage**: Stores `employees` and `salary_records` tables with strict foreign key constraints and performance indexes.

### Frontend *(Future Phase)*
* **Framework**: React with TypeScript
* **Responsibilities**: HR UI dashboard, employee directory table, search/filter controls, pagination, employee detail view, salary timeline, and analytics visualization.

### Testing Harness
* **Backend**: RSpec Rails (`rspec-rails`)
* **Frontend**: Vitest & React Testing Library

---

## 2. High-Level Architecture

```text
                    Browser (HR Manager)
                             |
                             | HTTP / JSON
                             v
                     React Application
                             |
                             | HTTP / JSON
                             v
                   Rails API Application
                             |
                   +---------+---------+
                   |                   |
                   v                   v
              Domain Models        Queries
                   |                   |
                   +---------+---------+
                             |
                             v
                      SQLite / Postgres
```

---

## 3. Assessment Requirements vs. Our Product Decisions

| Feature / Topic | Incubyte Assessment Requirement | Our Product Decision | Technical Implementation Choice |
| :--- | :--- | :--- | :--- |
| **Authentication** | Optional (Single HR Manager role) | Exclude Auth / Single Persona | Single HR user access model |
| **Salary Definition** | Open (Base salary reasonable) | Annual Gross Base Salary | Decimal amount with currency attribute |
| **Currencies** | Open (Local, FX, or both) | Local Currencies (No FX) | Per-currency analytics calculation |
| **Salary History** | Optional (Current salary sufficient) | Retain Salary History | `Employee` `has_many :salary_records` |
| **Employee Deletion** | Optional (Deletion not required) | Soft Deactivation | `status` enum (`active` / `inactive`), `dependent: :restrict_with_error` |
| **Database** | Open | SQLite (Dev/Test) | Active Record ORM with SQLite3 adapter |
| **Deployment** | Open (Public URL) | Platform Open | Selected during production readiness phase |

---

## 4. Phase Execution Roadmap

### Phase 1 — Technical Stack & Backend Foundation `[COMPLETED]`
- [x] Inspect repository & requirements
- [x] Initialize Rails API app in `backend/` with SQLite3
- [x] Configure RSpec Rails test harness
- [x] Verify Rails boot, DB connection, and baseline spec suite

### Phase 2 — Employee Domain `[COMPLETED]`
- [x] Migration for `employees` table with indexes (`employee_number`, `email`, `country`, `department`, `status`)
- [x] `Employee` Active Record model with string-backed `status` enum (`active`/`inactive`)
- [x] `before_validation` & `before_save` attribute normalization (`email.downcase`, `employee_number.upcase`)
- [x] RSpec model specs covering validations, uniqueness, case-insensitivity, normalization, and persistence (26 specs)

### Phase 3 — SalaryRecord Domain & Associations `[COMPLETED]`
- [x] Migration for `salary_records` table with foreign key to `employees` and `employee_id` index
- [x] `SalaryRecord` Active Record model with `belongs_to :employee`
- [x] `Employee` `has_many :salary_records, dependent: :restrict_with_error`
- [x] Validations for positive amount, ISO currency (`INR`, `USD`, `EUR`, `GBP`, `AUD`, `CAD`, `SGD`, `AED`), and date ordering (`effective_to >= effective_from`)
- [x] Model-level non-overlapping salary period validation (`no_overlapping_salary_periods`)
- [x] RSpec model specs covering validations, associations, boundary collisions, and foreign keys (18 specs; 44 total backend specs)

### Phase 4 — Employee & Salary API Endpoints `[NEXT PHASE]`
- [ ] Employee controller (`GET /api/v1/employees`, `GET /api/v1/employees/:id`, `POST /api/v1/employees`, `PATCH /api/v1/employees/:id`)
- [ ] Server-side pagination, search, and multi-column filtering
- [ ] Salary controller (`GET /api/v1/employees/:employee_id/salaries`, `POST /api/v1/employees/:employee_id/salaries`)
- [ ] Request specs for API endpoints and JSON serialization

### Phase 5 — Seed Dataset Generation
- [ ] Reproducible seed script populating ~10,000 employees and associated salary records
- [ ] Realistic distribution across 8 countries, 7 departments, and multiple currencies
- [ ] Seed script verification and performance logging

### Phase 6 — Analytics API & Calculations
- [ ] Salary insights endpoint (`GET /api/v1/salary-insights`)
- [ ] Analytics calculations (total count, average, median, min, max, country/department breakdowns) calculated per currency
- [ ] Analytics query specs

### Phase 7 — React Frontend Application
- [ ] React + TypeScript application initialization
- [ ] Application shell & navigation layout
- [ ] Employee directory table with search, filter, and pagination
- [ ] Employee details & salary timeline view
- [ ] HR Analytics Dashboard with interactive charts

### Phase 8 — Integration & Polish
- [ ] Connect React frontend to Rails API
- [ ] Loading states, empty states, and API error handling
- [ ] End-to-end user flow verification

### Phase 9 — Production Readiness & Deployment
- [ ] Environment variable configuration (`.env.example`)
- [ ] Production deployment setup
- [ ] Final verification & smoke testing

### Phase 10 — Documentation & AI Development Log
- [ ] Finalize `docs/ai-development-log.md`
- [ ] Root `README.md` with complete setup and execution instructions
- [ ] Review Git commit history for clear incremental progression
