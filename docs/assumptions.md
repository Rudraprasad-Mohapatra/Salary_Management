# Product & Technical Assumptions

## 1. Product & Domain Assumptions

### Assumption 1: Case-Insensitive Uniqueness for Employee Identifiers and Emails
* **Assumption**: `EMP-001` and `emp-001` represent the same employee identifier; `john@acme.com` and `John@acme.com` represent the same email address.
* **Impact**: Uniqueness validations enforce case-insensitive checks, backed by attribute normalization callbacks (`email.downcase`, `employee_number.upcase`).

### Assumption 2: Soft Deactivation via Status Flag (*Our Product Decision*)
* **Assumption**: Former or inactive employees should remain in the database with `status = "inactive"` so historical salary records and past organizational audits remain complete. Physical deletion (`destroy`) via standard API workflows is omitted.
* **Impact**: Salary history is preserved for audit compliance.

### Assumption 3: Open-Ended Effective Dates for Current Salaries
* **Assumption**: An employee's current active salary record has `effective_to = NULL`, indicating it is effective indefinitely until a new salary revision is awarded.
* **Impact**: A maximum of ONE open-ended salary record (`effective_to = NULL`) is permitted per employee at any given time.

### Assumption 4: Per-Currency Analytics Calculation (*Our Product Decision*)
* **Assumption**: Salaries are stored in their native currency (`INR`, `USD`, `EUR`, etc.) without automated foreign exchange conversion to preserve mathematical correctness.
* **Impact**: Analytics and salary insights calculate statistics (average, median, min, max) within each currency.

---

## 2. Distinction Summary

* **Incubyte Requirement**: 10,000 employee seed dataset, search/filter/pagination capabilities, flexible currency and analytics scope, simple maintainable codebase.
* **Our Product Decision**: Exclude authentication, define salary as annual gross base salary, retain salary history, use local currencies without FX conversion, use soft deactivation (`status = "inactive"`).
* **Technical Implementation Choice**: Rails API mode with SQLite3 (dev/test), string-backed `status` enum, attribute normalization callbacks, `dependent: :restrict_with_error`, model-level date range validation.
