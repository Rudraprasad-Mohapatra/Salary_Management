# Technical Implementation Details — Salary Management System

## Phase 2: Employee Domain Implementation

### 1. Database Schema (`employees` table)

| Column | Type | Options | Description |
| :--- | :--- | :--- | :--- |
| `id` | integer | primary key, auto-increment | Internal surrogate primary key |
| `employee_number` | string | null: false, unique index | Unique organizational employee identifier (e.g. `EMP-000001`) |
| `first_name` | string | null: false | Employee's given name |
| `last_name` | string | null: false | Employee's family name |
| `email` | string | null: false, unique index | Corporate email address |
| `country` | string | null: false, index | Employee's primary country of work |
| `department` | string | null: false, index | Organizational department (e.g. Engineering, Sales) |
| `job_title` | string | null: false | Primary role / position |
| `employment_type` | string | null: false | Employment relationship (e.g. Full Time, Part Time, Contract) |
| `status` | string | null: false, default: "active", index | Employment lifecycle status (`active` vs `inactive`) |
| `created_at` | datetime | null: false | Auto-managed creation timestamp |
| `updated_at` | datetime | null: false | Auto-managed update timestamp |

### 2. Indexes Strategy

1. `employees_on_employee_number` (`unique: true`): Enforces database-level uniqueness for employee identifiers and accelerates direct lookup queries (`WHERE employee_number = ?`).
2. `employees_on_email` (`unique: true`): Enforces database-level uniqueness for corporate emails and accelerates user/email searches.
3. `employees_on_country`: Optimizes filtering and aggregated analytics grouping by country (`WHERE country = ?`).
4. `employees_on_department`: Optimizes filtering and aggregated analytics grouping by department (`WHERE department = ?`).
5. `employees_on_status`: Speeds up filtering active vs inactive staff (`WHERE status = 'active'`).

---

## Phase 3: SalaryRecord Domain & Associations

### 1. Database Schema (`salary_records` table)

| Column | Type | Options | Description |
| :--- | :--- | :--- | :--- |
| `id` | integer | primary key, auto-increment | Internal surrogate primary key |
| `employee_id` | integer | null: false, foreign key, index | Foreign key referencing `employees.id` |
| `amount` | decimal(12, 2) | null: false | Salary compensation amount (must be > 0) |
| `currency` | string | null: false | ISO currency code (e.g. `INR`, `USD`, `EUR`) |
| `effective_from` | date | null: false | Start date of salary period |
| `effective_to` | date | null: true | End date of salary period (`NULL` indicates current active salary) |
| `created_at` | datetime | null: false | Auto-managed creation timestamp |
| `updated_at` | datetime | null: false | Auto-managed update timestamp |

### 2. Relational Architecture & Associations

* **Employee $\rightarrow$ SalaryRecords**: `has_many :salary_records, dependent: :restrict_with_error`.
  * *Rationale*: Preserves historical compensation data by preventing accidental physical deletion of employees with active or historic salary records.
* **SalaryRecord $\rightarrow$ Employee**: `belongs_to :employee`.
  * *Foreign Key Constraint*: Database-level foreign key (`add_foreign_key :salary_records, :employees`) prevents orphan salary records referencing non-existent employee IDs.

### 3. Business Rules & Model Validations

1. **Amount Validation**: Required (`presence: true`), must be strictly positive (`numericality: { greater_than: 0 }`).
2. **Currency Validation**: Required (`presence: true`), normalized to uppercase (`before_validation :normalize_currency`), and restricted to supported ISO codes (`INR`, `USD`, `EUR`, `GBP`, `AUD`, `CAD`, `SGD`, `AED`).
3. **Effective Date Ordering**: `effective_from` is required. If `effective_to` is provided, `effective_to` must be $\ge$ `effective_from`.
4. **Non-Overlapping Salary Period Rule**: Validates that an employee cannot have two salary records with overlapping date ranges $[A_{from}, A_{to}]$ and $[B_{from}, B_{to}]$.
   * *Overlap condition*: `(B.end.nil? || A.start <= B.end) && (A.end.nil? || B.start <= A.end)`.
   * *SQLite Exclusion Constraint Trade-Off*: Model-level validation is used because SQLite lacks native `EXCLUDE USING gist` range exclusion constraints available in PostgreSQL.

### 4. Verification Suite

* RSpec suite at [spec/models/salary_record_spec.rb](file:///f:/Salary_Management/backend/spec/models/salary_record_spec.rb) and [spec/models/employee_spec.rb](file:///f:/Salary_Management/backend/spec/models/employee_spec.rb) covering 44 total test cases with 0 failures.
