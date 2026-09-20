require 'rails_helper'

RSpec.describe SalaryRecord, type: :model do
  let(:employee) do
    Employee.create!(
      employee_number: "EMP-000001",
      first_name: "Rahul",
      last_name: "Sharma",
      email: "rahul.sharma@acme.com",
      country: "India",
      department: "Engineering",
      job_title: "Senior Software Engineer",
      employment_type: "Full Time",
      status: "active"
    )
  end

  let(:other_employee) do
    Employee.create!(
      employee_number: "EMP-000002",
      first_name: "Priya",
      last_name: "Patel",
      email: "priya.patel@acme.com",
      country: "India",
      department: "Product",
      job_title: "Product Manager",
      employment_type: "Full Time",
      status: "active"
    )
  end

  let(:valid_attributes) do
    {
      employee: employee,
      amount: 1000000.00,
      currency: "INR",
      effective_from: Date.new(2025, 1, 1),
      effective_to: nil
    }
  end

  subject { SalaryRecord.new(valid_attributes) }

  describe "Validations" do
    context "1. Valid salary record" do
      it "is valid with proper attributes" do
        expect(subject).to be_valid
      end
    end

    context "2. Employee required" do
      it "is invalid without an employee" do
        subject.employee = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:employee]).to include("must exist").or include("can't be blank")
      end
    end

    context "3. Amount required" do
      it "is invalid without an amount" do
        subject.amount = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:amount]).to include("can't be blank")
      end
    end

    context "4. Amount positive" do
      it "is invalid with zero amount" do
        subject.amount = 0
        expect(subject).not_to be_valid
        expect(subject.errors[:amount]).to include("must be greater than 0")
      end

      it "is invalid with negative amount" do
        subject.amount = -50000
        expect(subject).not_to be_valid
        expect(subject.errors[:amount]).to include("must be greater than 0")
      end
    end

    context "5. Currency required & supported" do
      it "is invalid without currency" do
        subject.currency = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:currency]).to include("can't be blank")
      end

      it "is invalid with an unsupported currency code" do
        subject.currency = "XYZ"
        expect(subject).not_to be_valid
        expect(subject.errors[:currency]).to include("is not included in the list")
      end

      it "normalizes currency to uppercase and strips whitespace" do
        salary = SalaryRecord.new(valid_attributes.merge(currency: "  usd  "))
        salary.valid?
        expect(salary.currency).to eq("USD")
      end
    end

    context "6. Effective_from required" do
      it "is invalid without effective_from" do
        subject.effective_from = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:effective_from]).to include("can't be blank")
      end
    end

    context "7. Effective_to can be NULL" do
      it "is valid when effective_to is nil (current salary)" do
        subject.effective_to = nil
        expect(subject).to be_valid
      end
    end

    context "8. Effective_to date order" do
      it "is invalid when effective_to is before effective_from" do
        subject.effective_from = Date.new(2025, 6, 1)
        subject.effective_to = Date.new(2025, 5, 1)
        expect(subject).not_to be_valid
        expect(subject.errors[:effective_to]).to include("must be on or after effective_from")
      end

      it "allows effective_to equal to effective_from" do
        subject.effective_from = Date.new(2025, 6, 1)
        subject.effective_to = Date.new(2025, 6, 1)
        expect(subject).to be_valid
      end
    end
  end

  describe "Associations" do
    context "9 & 10. salary_record.employee" do
      it "belongs to and returns the associated employee" do
        record = SalaryRecord.create!(valid_attributes)
        expect(record.employee).to eq(employee)
      end
    end

    context "11. employee.salary_records" do
      it "allows creating salary records through employee.salary_records.create!" do
        created_record = employee.salary_records.create!(
          amount: 75000.00,
          currency: "USD",
          effective_from: Date.new(2025, 1, 1),
          effective_to: nil
        )

        expect(employee.salary_records).to include(created_record)
        expect(created_record.employee_id).to eq(employee.id)
      end

      it "prevents deleting an employee with dependent salary records (dependent: :restrict_with_error)" do
        employee.salary_records.create!(
          amount: 75000.00,
          currency: "USD",
          effective_from: Date.new(2025, 1, 1),
          effective_to: nil
        )

        expect(employee.destroy).to be false
        expect(employee.errors[:base]).to include("Cannot delete record because dependent salary records exist")
      end
    end
  end

  describe "Salary Period Rules & Boundary Semantics" do
    context "12. Sequential non-overlapping records" do
      it "allows sequential non-overlapping salary records (July 1 following June 30)" do
        SalaryRecord.create!(
          employee: employee,
          amount: 50000,
          currency: "INR",
          effective_from: Date.new(2025, 1, 1),
          effective_to: Date.new(2025, 6, 30)
        )

        second_record = SalaryRecord.new(
          employee: employee,
          amount: 55000,
          currency: "INR",
          effective_from: Date.new(2025, 7, 1),
          effective_to: Date.new(2025, 12, 31)
        )

        expect(second_record).to be_valid

        second_record.save!

        third_record = SalaryRecord.new(
          employee: employee,
          amount: 60000,
          currency: "INR",
          effective_from: Date.new(2026, 1, 1),
          effective_to: nil
        )

        expect(third_record).to be_valid
      end
    end

    context "Boundary collision rejection (Inclusive Dates)" do
      it "rejects a new period starting on the exact end date of an existing period (same-day collision)" do
        SalaryRecord.create!(
          employee: employee,
          amount: 50000,
          currency: "INR",
          effective_from: Date.new(2025, 1, 1),
          effective_to: Date.new(2025, 6, 30)
        )

        same_day_collision = SalaryRecord.new(
          employee: employee,
          amount: 55000,
          currency: "INR",
          effective_from: Date.new(2025, 6, 30),
          effective_to: Date.new(2025, 12, 31)
        )

        expect(same_day_collision).not_to be_valid
        expect(same_day_collision.errors[:base]).to include("Salary period overlaps with an existing record")
      end
    end

    context "13. Overlapping salary periods" do
      it "rejects overlapping date ranges for the same employee" do
        SalaryRecord.create!(
          employee: employee,
          amount: 50000,
          currency: "INR",
          effective_from: Date.new(2025, 1, 1),
          effective_to: Date.new(2025, 6, 30)
        )

        overlapping = SalaryRecord.new(
          employee: employee,
          amount: 55000,
          currency: "INR",
          effective_from: Date.new(2025, 6, 15),
          effective_to: Date.new(2025, 12, 31)
        )

        expect(overlapping).not_to be_valid
        expect(overlapping.errors[:base]).to include("Salary period overlaps with an existing record")
      end
    end

    context "14. Multiple open-ended records" do
      it "rejects a second open-ended salary record for the same employee" do
        SalaryRecord.create!(
          employee: employee,
          amount: 50000,
          currency: "INR",
          effective_from: Date.new(2025, 1, 1),
          effective_to: nil
        )

        second_open_ended = SalaryRecord.new(
          employee: employee,
          amount: 60000,
          currency: "INR",
          effective_from: Date.new(2025, 7, 1),
          effective_to: nil
        )

        expect(second_open_ended).not_to be_valid
        expect(second_open_ended.errors[:base]).to include("Salary period overlaps with an existing record")
      end
    end

    context "15. Different employees do not conflict" do
      it "allows identical salary period dates for different employees" do
        SalaryRecord.create!(
          employee: employee,
          amount: 50000,
          currency: "INR",
          effective_from: Date.new(2025, 1, 1),
          effective_to: Date.new(2025, 12, 31)
        )

        other_employee_record = SalaryRecord.new(
          employee: other_employee,
          amount: 50000,
          currency: "INR",
          effective_from: Date.new(2025, 1, 1),
          effective_to: Date.new(2025, 12, 31)
        )

        expect(other_employee_record).to be_valid
      end
    end

    context "Self-update behavior" do
      it "allows updating an existing SalaryRecord without self-overlap false positives" do
        existing_record = SalaryRecord.create!(
          employee: employee,
          amount: 50000,
          currency: "INR",
          effective_from: Date.new(2025, 1, 1),
          effective_to: nil
        )

        existing_record.amount = 52000
        existing_record.effective_to = Date.new(2025, 12, 31)

        expect(existing_record).to be_valid
        expect(existing_record.save).to be true
      end
    end

    context "16. Database foreign key enforcement" do
      it "raises ActiveRecord::InvalidForeignKey when inserting invalid employee_id directly" do
        invalid_record = SalaryRecord.new(
          employee_id: 999999,
          amount: 50000,
          currency: "INR",
          effective_from: Date.new(2025, 1, 1),
          effective_to: nil
        )

        expect { invalid_record.save!(validate: false) }.to raise_error(ActiveRecord::InvalidForeignKey)
      end
    end
  end
end
