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

### 3. Model Architecture & Normalization (`app/models/employee.rb`)

* **Status Enum**: Implemented via Rails string-backed enum `enum :status, { active: "active", inactive: "inactive" }, default: "active"`. Stores human-readable string values directly in SQL while providing query helpers (`active?`, `inactive!`, `Employee.active`).
* **Attribute Normalization**: Callbacks (`before_validation` and `before_save`) automatically canonicalize attribute values:
  * `email`: Stripped of whitespace and downcased (`" RAHUL.SHARMA@ACME.COM "` $\rightarrow$ `"rahul.sharma@acme.com"`).
  * `employee_number`: Stripped of whitespace and uppercased (`" emp-000001 "` $\rightarrow$ `"EMP-000001"`).
  * `first_name`, `last_name`: Stripped of leading/trailing whitespace.
* **Validations**:
  * `employee_number`: Required (`presence: true`), case-insensitive uniqueness (`uniqueness: { case_sensitive: false }`).
  * `first_name`, `last_name`, `country`, `department`, `job_title`, `employment_type`: Required (`presence: true`).
  * `email`: Required (`presence: true`), case-insensitive uniqueness (`uniqueness: { case_sensitive: false }`), validated against `URI::MailTo::EMAIL_REGEXP`.
  * `status`: Required (`presence: true`), restricted to `%w[active inactive]`.

### 4. Verification Suite

* RSpec model spec at [spec/models/employee_spec.rb](file:///f:/Salary_Management/backend/spec/models/employee_spec.rb) covering valid attributes, presence of required attributes, case-insensitive uniqueness, email format validation, attribute normalization callbacks, enum status behavior, DB constraint consistency, and database persistence/retrieval (26 examples, 0 failures).
