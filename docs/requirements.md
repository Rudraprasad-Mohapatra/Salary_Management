# ACME Salary Management System — Product Requirements Document (PRD)

**Document Version:** 1.1.0  
**Target Persona:** HR Manager (ACME Corp — 10,000 Employees across Global Offices)  
**Engineering Framing:** Incubyte Software Craftsperson Assessment

---

## 1. Goal & Product Vision
ACME Corp currently manages salary data for 10,000 employees across multiple countries using static Excel spreadsheets. This process is tedious, error-prone, lacks audit history, and makes answering executive questions about organizational compensation difficult.

**Goal:** Build an end-to-end web application that empowers the HR Manager to manage employee records, track complete salary revision histories, and gain instant, interactive insights into organizational salary distributions across countries, departments, and currencies.

---

## 2. Target User Persona
- **Role:** HR Manager at ACME Corp
- **Needs:** Fast employee lookup, ability to revise salaries while preserving historic comp data, deactivating former employees, and answering key questions on global pay distribution (e.g. median/average pay by country and department).

---

## 3. Scope & Key Capabilities

### A. Employee Lifecycle Management
- **Directory & Search:** View, search (by name, email, employee number), and filter (by department, country, status).
- **Employee CRUD:** View employee profile, create new employee, edit employee details, and deactivate/archive employee (retaining salary history for compliance).
- **Employee Schema:** `employee_number` (unique e.g. `EMP-004321`), `first_name`, `last_name`, `email`, `country`, `department`, `job_title`, `employment_type` (Full Time / Part Time / Contract), `status` (Active / Inactive).

### B. Salary & History Management
- **Historic Salary Records:** Every salary change creates a new immutable `SalaryRecord` with `amount`, `currency`, `effective_from`, and optional `effective_to`.
- **Domain Validation Rule:** An employee cannot have two active/overlapping salary records covering the same effective date range.
- **Salary History View:** Displays an employee's historic progression (e.g., ₹750,000 in 2024 → ₹950,000 in 2025 → ₹1,200,000 in 2026).

### C. Salary Insights & Analytics Dashboard ("How ACME Pays People")
- **Aggregated Metrics:** Total Employees, Average Salary, Median Salary, Highest Salary, Lowest Salary.
- **Independent Currency Grouping:** To maintain mathematical integrity without arbitrary FX conversions, salary stats are calculated per currency (or normalized to USD with toggle).
- **Interactive Multi-Param Filtering:** Filter insights by Country (e.g., India, USA, UK), Department (e.g., Engineering, Product, Sales), Job Title, and Currency (INR, USD, EUR, GBP, etc.).
- **Visual Distributions:** Department-wise and country-wise salary breakdown charts.

### D. 10,000 Employee Dataset & Seeding
- Seed script populates **10,000 realistic employee records** with associated historical salary records across 8 countries and 8 departments, optimized for sub-50ms query responses.

---

## 4. Non-Goals (Deliberately Out of Scope) & Rationale

| Feature Left Out | Engineering / Product Rationale |
| :--- | :--- |
| **Direct Bank Payroll Processing & Tax Handling** | This is a compensation management & analytics tool. Disbursal rails, tax withholding, and benefit deductions belong to separate domain services (e.g. Gusto/ADP integrations). |
| **Complex Multi-Role SSO / OAuth** | The application is designed specifically for the HR Manager persona. Adding full auth/RBAC introduces auth boilerplate without adding value to core comp analytics evaluation. |
| **Live Foreign Exchange (FX) Webhook Integrations** | Real-time FX rates introduce non-deterministic external network calls into unit testing. Currency analytics are evaluated per currency (Option A) with optional static conversion tables. |
| **Employee Self-Service Portal** | Out of scope for this assessment; focus remains on HR organizational decision-making and salary analytics. |

---

## 5. Success Criteria
1. HR manager can manage employee records and deactivate staff without losing historical records.
2. Complete salary history is preserved and validated against overlapping effective dates.
3. HR manager can search, filter, and paginate 10,000 employees instantly (< 50ms database queries).
4. Salary insights dashboard answers key executive questions regarding pay distribution by country, department, and currency.
5. High test coverage with deterministic backend RSpec/Pytest tests and frontend Vitest suite.
