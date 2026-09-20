# ACME Salary Management System — Product Requirements Document (PRD)

## 1. Problem Statement
ACME Corp currently manages salary data for approximately 10,000 employees across multiple countries using static spreadsheets. This spreadsheet-based process lacks centralization, makes employee search and filtering difficult, increases data inconsistency risks, and impedes HR's ability to answer executive questions regarding organizational pay distribution.

## 2. Primary Persona
* **HR Manager**: Responsible for managing employee records, tracking compensation details, and analyzing global salary distributions across countries, departments, and roles.

## 3. Assessment Requirements (Incubyte Clarifications)
The Incubyte assessment establishes the following core requirements:
* **Centralized Web Application**: A functional web application enabling an HR Manager to manage employee and salary data.
* **10,000 Employee Dataset & Seeding**: A reproducible seed mechanism creating ~10,000 realistic employees across multiple countries, departments, and roles.
* **Search, Filtering & Pagination**: HR Manager must be able to search (by name/email/number), filter (by country/department/status), and paginate employee results without overwhelming browser memory.
* **Simple, Maintainable Architecture**: Craftsmanship-focused implementation favoring simplicity, correctness, and comprehensive automated test coverage over complex infrastructure.
* **Open Assessment Scope (Incubyte Flexibility)**: Single HR Manager role is sufficient (auth not explicitly required); current annual base salary is sufficient (salary history optional); currency semantics are open; analytics metric choices are open; deployment platform is open.

## 4. MVP Scope
* **Employee Directory**: Searchable, filterable, and paginated table of employees with profile views.
* **Employee Management**: Create new employees, update details, and manage employment status (`active` vs `inactive`).
* **Salary Management**: Assign annual gross base salary with currency and effective date range.
* **Salary Insights & Analytics**: Dashboard providing employee counts, salary statistics (average, median, min, max), and distribution breakdowns across countries and departments.

## 5. Deliberate Product Decisions (Our Choices vs. Assessment Options)

| Area | Assessment Requirement | Our Deliberate Product Decision | Rationale |
| :--- | :--- | :--- | :--- |
| **Authentication** | Optional (Single HR Manager role sufficient) | **Exclude Auth / Single Persona** | Avoids auth boilerplate; focuses strictly on core salary analytics. |
| **Salary Definition** | Open (Base salary reasonable) | **Annual Gross Base Salary** | Establishes a standard, deterministic compensation figure. Excludes payroll, tax, bonuses, and benefits. |
| **Currencies** | Open (Local, FX, or both) | **Local Currencies / Separate Analytics** | Calculates salary statistics within each currency (INR, USD, EUR, etc.). Excludes FX conversion to avoid arbitrary exchange rate assumptions. |
| **Salary History** | Optional (Current salary sufficient) | **Preserve Salary History** | *Product enhancement beyond minimum requirement*: Retains historical salary records (`has_many :salary_records`) to track progression and prevent destructive overwriting. |
| **Employee Lifecycle**| Open (Deletion optional) | **Soft Deactivation (`active`/`inactive`)** | Avoids physical DB deletion (`dependent: :restrict_with_error`) to preserve historical compensation audit trails. |
| **Deployment** | Open (Any accessible functional URL) | **Platform Open** | Deployment target will be selected during production readiness based on simplicity. |

## 6. Explicit Non-Goals
* **Payroll & Tax Processing**: No payroll execution, tax withholding, or social security calculations.
* **Automated Currency Conversion**: No live or historical FX exchange rate conversions.
* **Employee Self-Service**: No portal access for non-HR employees.
* **Distributed Architecture**: No microservices, Kafka, Elasticsearch, or Kubernetes.

## 7. Success Criteria
1. HR Manager can search, filter, and paginate 10,000 seeded employees seamlessly.
2. Employee records can be created, updated, and deactivated without data corruption.
3. Salary revisions are recorded with effective dates and validated against overlapping date ranges.
4. Analytics dashboard provides instant salary statistics grouped cleanly by currency.
5. Automated test suite (RSpec backend) passes deterministically.

## 8. Open Decisions
* **Production Deployment Host**: Render, Fly.io, or AWS (to be finalized during Phase 8).