# Salary Management System

## 1. Product Goal

Build a web-based salary management system for an organization with approximately **10,000 employees** across multiple countries.

The system replaces spreadsheet-based salary management and enables an HR Manager to:

1. Manage employee information.
2. Manage employee salary information.
3. Preserve salary history.
4. Search and filter employees.
5. Understand how the organization pays its employees through salary insights and analytics.

The goal is to build a simple, maintainable, production-quality MVP rather than an unnecessarily complex system.

---

# 2. Primary User

## HR Manager

The HR Manager is responsible for managing employee and salary information across the organization.

The MVP is designed primarily around the HR Manager's workflow.

---

# 3. Problem Statement

ACME currently manages salary information for approximately 10,000 employees across multiple countries using spreadsheets.

This creates problems such as:

* difficult employee search
* difficult salary updates
* poor visibility into salary history
* difficulty answering organizational salary questions
* difficulty filtering salary information by country, department, or role
* increased risk of inconsistent or duplicated data

The proposed application provides a centralized system for managing and analyzing this information.

---

# 4. MVP Scope

## 4.1 Employee Management

The HR Manager should be able to:

* View employees.
* Search employees.
* Filter employees.
* Paginate employee results.
* View an employee's details.
* Create an employee.
* Update an employee.
* Deactivate an employee.

Employee information should include, at minimum:

* Employee ID
* First name
* Last name
* Email
* Country
* Department
* Job title
* Employment type
* Employment status

---

# 5. Salary Management

The HR Manager should be able to:

* View an employee's current salary.
* Add a salary record.
* View salary history.
* Preserve previous salary records.
* Associate salary with a currency.
* Associate salary with an effective date.

Salary changes must not overwrite historical information.

For example:

Employee:

```text
Rahul Sharma
```

Salary history:

```text
2024 → ₹700,000
2025 → ₹850,000
2026 → ₹1,000,000
```

The system should preserve all of these records.

---

# 6. Salary Data

Each salary record should contain information such as:

* Employee
* Salary amount
* Currency
* Effective date
* End date where applicable
* Creation timestamp
* Update timestamp

Salary amounts must be positive.

Currencies must be valid.

The system should prevent logically inconsistent salary periods.

---

# 7. Salary Insights

The HR Manager should be able to understand how the organization pays employees.

The dashboard should provide useful metrics such as:

* Total employees
* Average salary
* Median salary
* Minimum salary
* Maximum salary
* Salary distribution
* Salary breakdown by country
* Salary breakdown by department
* Salary breakdown by job title

The HR Manager should be able to filter salary insights by:

* Country
* Department
* Job title
* Currency

---

# 8. Multiple Currencies

Employees may belong to different countries and therefore may have salaries in different currencies.

The MVP will **not automatically combine different currencies into a single salary statistic**.

For example:

```text
INR
Average: ₹1,200,000

USD
Average: $85,000

EUR
Average: €72,000
```

Instead, salary statistics should be calculated within a currency.

### Reason

Cross-currency calculations require:

* exchange-rate data
* source of exchange rates
* effective exchange-rate dates
* handling historical exchange rates
* decisions about the organization's reporting currency

These concerns are outside the core salary-management problem and are therefore intentionally excluded from the MVP.

---

# 9. Employee Search and Filtering

The employee list should support:

### Search

Search by useful employee information such as:

* employee ID
* first name
* last name
* email

### Filters

Allow filtering by:

* country
* department
* job title
* employment status

### Pagination

Employee results should be paginated rather than loading all 10,000 employees into the browser at once.

---

# 10. Employee Lifecycle

Employees should not normally be physically deleted because employee salary history may need to remain available.

Instead, an employee should be able to become:

```text
Active
Inactive
```

Deactivation preserves historical data.

---

# 11. Seed Data

The application must include a reproducible seed mechanism that creates approximately:

**10,000 employees**

Seed data should represent a realistic organization with:

* multiple countries
* multiple departments
* multiple job titles
* multiple employment types
* multiple currencies
* salary records
* salary history

The seed process should be documented.

---

# 12. Non-Goals

The following are intentionally outside the MVP.

## Payroll

The system will not calculate or process payroll.

## Tax

The system will not calculate:

* income tax
* social security
* country-specific deductions

## Benefits

The system will not manage:

* health insurance
* retirement benefits
* bonuses
* allowances

## Attendance

The system will not manage:

* attendance
* working hours
* leave

## Employee Self-Service

Employees themselves are not primary users of the MVP.

## External Compensation Benchmarking

The system will not compare salaries against external companies or market salary databases.

## Currency Conversion

The MVP will not provide automatic exchange-rate conversion.

## Payroll Integrations

The MVP will not integrate with external payroll providers.

## Complex Distributed Architecture

The application will not use microservices, Kafka, Kubernetes, Elasticsearch, or other distributed infrastructure unless a demonstrated requirement emerges.

---

# 13. Expected Technical Solution

The application should provide:

```text
React frontend
       |
       | HTTP / JSON
       |
Rails backend
       |
       |
SQLite database
```

The backend should expose APIs for:

* employees
* salary records
* salary insights

The frontend should provide a usable HR interface.

---

# 14. Testing Requirements

The application should contain meaningful automated tests covering core behavior.

Tests should be:

* fast
* deterministic
* understandable
* focused on business behavior

Important areas include:

### Employee

* creation
* validation
* uniqueness
* search
* filtering

### Salary

* creation
* positive amount validation
* currency validation
* salary history
* effective dates
* invalid salary periods

### Analytics

* average
* median
* minimum
* maximum
* currency filtering
* country filtering
* department filtering
* empty result sets

### API

Important endpoints and error responses should be tested.

---

# 15. Performance Expectations

The application should reasonably handle the provided dataset of approximately 10,000 employees.

The solution should use:

* database-level filtering
* pagination
* appropriate indexes
* efficient queries
* avoidance of obvious N+1 queries

10,000 employees does not justify a distributed architecture.

---

# 16. Product Success Criteria

The MVP is successful if an HR Manager can:

1. Find an employee.
2. Filter employees.
3. View employee information.
4. View current salary.
5. View salary history.
6. Add/update salary information.
7. Understand salary distribution.
8. Filter salary insights.
9. Work with multiple currencies.
10. Manage approximately 10,000 employees without loading the entire dataset into the browser.

---

# 17. Assessment Artifacts

The repository should contain documentation explaining:

* requirements
* implementation plan
* architecture
* technical decisions
* assumptions
* performance considerations
* AI-assisted development
* deployment

The Git history should contain incremental commits showing how the system evolved.

---

# 18. Important Product Principle

The system should favor:

**simplicity + correctness + maintainability**

over:

**complexity + unnecessary infrastructure + excessive features**

The assessment explicitly values engineering judgment rather than system complexity.