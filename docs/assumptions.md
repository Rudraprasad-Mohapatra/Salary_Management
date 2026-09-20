# Product & Technical Assumptions

## Assumption 1: Case-Insensitive Uniqueness for Employee Identifiers and Emails

* **Assumption**: `EMP-001` and `emp-001` represent the same employee identifier; `john@acme.com` and `John@acme.com` represent the same email address.
* **Impact**: Uniqueness validations enforce case-insensitive checks.

## Assumption 2: Soft Deactivation via Status Flag

* **Assumption**: Former or inactive employees should remain in the database with `status = "inactive"` so historical salary records and past organizational audits remain complete.
* **Impact**: Physical deletion (`destroy`) is avoided in standard HR workflows.
