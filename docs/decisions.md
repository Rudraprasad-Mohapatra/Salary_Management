# Engineering Decision Log

## Decision 1: Exclude Authentication & Single Persona Focus (*Our Product Decision*)

* **Context**: Incubyte clarified that authentication/authorization is optional and a single HR Manager role is sufficient.
* **Decision**: Exclude authentication/authorization from the MVP scope.
* **Rationale**: Focuses implementation strictly on core employee directory, salary history, and salary analytics.

## Decision 2: String-Backed Enum for Employee Status (*Technical Choice*)

* **Context**: Employees are deactivated rather than physically deleted (`active` vs `inactive`). We needed an appropriate Rails representation for `status`.
* **Decision**: Use a string-backed Rails enum: `enum :status, { active: "active", inactive: "inactive" }, default: "active"`.
* **Rationale**:
  1. Storing literal string values (`"active"`, `"inactive"`) directly in the database keeps raw SQL queries, logs, and database inspection readable without requiring integer-to-name lookup mapping tables.
  2. Leverages full Rails enum convenience methods (`employee.active?`, `employee.inactive!`, `Employee.active` scope).
  3. Avoids brittle integer position mapping issues if new statuses are added in future iterations.

## Decision 3: Dual Uniqueness Enforcement (Rails Model + Database Unique Indexes) (*Technical Choice*)

* **Context**: `employee_number` and `email` must be strictly unique across the organization.
* **Decision**: Implement case-insensitive validation in `Employee` model (`validates ..., uniqueness: { case_sensitive: false }`) AND create `UNIQUE` database indexes in SQLite/PostgreSQL migration (`add_index :employees, ..., unique: true`).
* **Rationale**: Application-level validations suffer from race conditions under concurrent requests. The database unique index guarantees absolute data integrity at the storage layer.

## Decision 4: Attribute Normalization Callbacks for Validation and Database Consistency (*Technical Choice*)

* **Context**: Rails model validation specified `uniqueness: { case_sensitive: false }`, whereas database unique indexes (`add_index :employees, :email, unique: true`) use case-sensitive BINARY collation in SQLite by default. Without normalization, bypassing Rails validation allows case-differing duplicate records (e.g., `user@acme.com` and `USER@ACME.COM`) to co-exist in the database.
* **Decision**: Implement `before_validation` and `before_save` normalization callbacks in `Employee`:
  * `email`: `.strip.downcase`
  * `employee_number`: `.strip.upcase`
  * `first_name`, `last_name`: `.strip`
* **Rationale**:
  1. Ensures all data stored in SQL is canonical (lowercase emails, uppercase employee numbers).
  2. Harmonizes application validation and database unique index semantics—because values are normalized prior to DB operations, SQLite's binary unique index triggers atomically even if validation is bypassed.
  3. Simple, maintainable, zero external gems, works across SQLite and PostgreSQL.

## Decision 5: `dependent: :restrict_with_error` for Employee-SalaryRecord Association (*Our Product Decision*)

* **Context**: Salary management requires maintaining audit history of past compensation revisions. Silently deleting salary records when an employee is deleted violates audit integrity.
* **Decision**: Configure `has_many :salary_records, dependent: :restrict_with_error` on `Employee`.
* **Rationale**: Prevents accidental physical deletion of employees with associated salary records at the Rails layer by adding a validation error instead of cascading deletion.

## Decision 6: Model-Level Validation for Non-Overlapping Salary Date Ranges (*Technical Choice*)

* **Context**: An employee cannot have two active or overlapping salary records covering the same period.
* **Decision**: Implement a model-level custom validation (`no_overlapping_salary_periods`) in `SalaryRecord`.
* **Rationale**: SQLite does not support native PostgreSQL `EXCLUDE USING gist` date range exclusion constraints. Implementing the date overlap validation in Active Record provides portable, cross-database protection without introducing database-specific SQL extensions or complex gems.

## Decision 7: Local Currency Handling & Separate Currency Analytics (*Our Product Decision*)

* **Context**: Incubyte left currency handling open (local currency, FX conversion, or both).
* **Decision**: Retain salaries in local currencies (`INR`, `USD`, `EUR`, etc.) and compute analytics separately within each currency without automated FX conversion.
* **Rationale**: Avoids non-deterministic or arbitrary exchange rate assumptions and ensures mathematical precision in compensation reporting.
