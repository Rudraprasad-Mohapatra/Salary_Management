# Product & Technical Assumptions

## Assumption 1: Case-Insensitive Uniqueness for Employee Identifiers and Emails

* **Assumption**: `EMP-001` and `emp-001` represent the same employee identifier; `john@acme.com` and `John@acme.com` represent the same email address.
* **Impact**: Uniqueness validations enforce case-insensitive checks.

## Assumption 2: Soft Deactivation via Status Flag

* **Assumption**: Former or inactive employees should remain in the database with `status = "inactive"` so historical salary records and past organizational audits remain complete.
* **Impact**: Physical deletion (`destroy`) is avoided in standard HR workflows.

## Assumption 3: Open-Ended Effective Dates for Current Salaries

* **Assumption**: An employee's current active salary record has `effective_to = NULL`, indicating it is effective indefinitely until a new salary revision is awarded.
* **Impact**: A maximum of ONE open-ended salary record (`effective_to = NULL`) is permitted per employee at any given time.

## Assumption 4: Per-Currency Analytics Calculation

* **Assumption**: Salaries are stored in their native currency (`INR`, `USD`, `EUR`, etc.) without automated foreign exchange conversion to preserve mathematical correctness.
* **Impact**: Analytics and salary insights will calculate metrics per currency.
