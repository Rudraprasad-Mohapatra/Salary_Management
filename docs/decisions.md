# Engineering Decision Log

## Decision 1: String-Backed Enum for Employee Status

* **Context**: Employees must be deactivated rather than physically deleted (`active` vs `inactive`). We needed an appropriate Rails representation for `status`.
* **Decision**: Use a string-backed Rails enum: `enum :status, { active: "active", inactive: "inactive" }, default: "active"`.
* **Rationale**:
  1. Storing literal string values (`"active"`, `"inactive"`) directly in the database keeps raw SQL queries, logs, and database inspection readable without requiring integer-to-name lookup mapping tables.
  2. Leverages full Rails enum convenience methods (`employee.active?`, `employee.inactive!`, `Employee.active` scope).
  3. Avoids brittle integer position mapping issues if new statuses are added in future iterations.

## Decision 2: Dual Uniqueness Enforcement (Rails Model + Database Unique Indexes)

* **Context**: `employee_number` and `email` must be strictly unique across the organization.
* **Decision**: Implement case-insensitive validation in `Employee` model (`validates ..., uniqueness: { case_sensitive: false }`) AND create `UNIQUE` database indexes in SQLite/PostgreSQL migration (`add_index :employees, ..., unique: true`).
* **Rationale**: Application-level validations suffer from race conditions under concurrent requests. The database unique index guarantees absolute data integrity at the storage layer.

## Decision 3: Standard URI Email Regex for Format Validation

* **Context**: Email formatting validation must prevent invalid email inputs without over-engineering RFC 5322 compliance.
* **Decision**: Use `URI::MailTo::EMAIL_REGEXP` provided out-of-the-box by Ruby's standard library.
* **Rationale**: Simple, maintainable, standard-compliant without requiring custom complex regex or external gems.

## Decision 4: Attribute Normalization Callbacks for Validation and Database Consistency

* **Context**: Rails model validation specified `uniqueness: { case_sensitive: false }`, whereas database unique indexes (`add_index :employees, :email, unique: true`) use case-sensitive BINARY collation in SQLite by default. Without normalization, bypassing Rails validation allows case-differing duplicate records (e.g., `user@acme.com` and `USER@ACME.COM`) to co-exist in the database.
* **Decision**: Implement `before_validation` and `before_save` normalization callbacks in `Employee`:
  * `email`: `.strip.downcase`
  * `employee_number`: `.strip.upcase`
  * `first_name`, `last_name`: `.strip`
* **Rationale**:
  1. Ensures all data stored in SQL is canonical (lowercase emails, uppercase employee numbers).
  2. Harmonizes application validation and database unique index semantics—because values are normalized prior to DB operations, SQLite's binary unique index triggers atomically even if validation is bypassed.
  3. Simple, maintainable, zero external gems, works across SQLite and PostgreSQL.
