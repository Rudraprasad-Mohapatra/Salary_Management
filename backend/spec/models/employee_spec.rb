require 'rails_helper'

RSpec.describe Employee, type: :model do
  let(:valid_attributes) do
    {
      employee_number: "EMP-000001",
      first_name: "Rahul",
      last_name: "Sharma",
      email: "rahul.sharma@acme.com",
      country: "India",
      department: "Engineering",
      job_title: "Senior Software Engineer",
      employment_type: "Full Time",
      status: "active"
    }
  end

  subject { Employee.new(valid_attributes) }

  describe "Validations" do
    context "with valid attributes" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "required fields" do
      it "is invalid without an employee_number" do
        subject.employee_number = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:employee_number]).to include("can't be blank")
      end

      it "is invalid without a first_name" do
        subject.first_name = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:first_name]).to include("can't be blank")
      end

      it "is invalid without a last_name" do
        subject.last_name = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:last_name]).to include("can't be blank")
      end

      it "is invalid without an email" do
        subject.email = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:email]).to include("can't be blank")
      end

      it "is invalid without a country" do
        subject.country = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:country]).to include("can't be blank")
      end

      it "is invalid without a department" do
        subject.department = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:department]).to include("can't be blank")
      end

      it "is invalid without a job_title" do
        subject.job_title = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:job_title]).to include("can't be blank")
      end

      it "is invalid without an employment_type" do
        subject.employment_type = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:employment_type]).to include("can't be blank")
      end

      it "is invalid without a status" do
        subject.status = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:status]).to include("can't be blank")
      end
    end

    context "employee_number uniqueness" do
      it "is invalid with a duplicate employee_number" do
        Employee.create!(valid_attributes)
        duplicate_employee = Employee.new(valid_attributes.merge(email: "different@acme.com"))
        
        expect(duplicate_employee).not_to be_valid
        expect(duplicate_employee.errors[:employee_number]).to include("has already been taken")
      end

      it "enforces case-insensitive uniqueness for employee_number" do
        Employee.create!(valid_attributes.merge(employee_number: "EMP-001"))
        duplicate_employee = Employee.new(valid_attributes.merge(employee_number: "emp-001", email: "other@acme.com"))

        expect(duplicate_employee).not_to be_valid
        expect(duplicate_employee.errors[:employee_number]).to include("has already been taken")
      end
    end

    context "email validation" do
      it "is invalid with an improperly formatted email" do
        invalid_emails = ["plainaddress", "john.doe@", "@acme.com", "john.doe@acme,com"]
        invalid_emails.each do |invalid_email|
          subject.email = invalid_email
          expect(subject).not_to be_valid
          expect(subject.errors[:email]).to include("is invalid")
        end
      end

      it "is invalid with a duplicate email" do
        Employee.create!(valid_attributes)
        duplicate_employee = Employee.new(valid_attributes.merge(employee_number: "EMP-000002"))

        expect(duplicate_employee).not_to be_valid
        expect(duplicate_employee.errors[:email]).to include("has already been taken")
      end

      it "enforces case-insensitive uniqueness for email" do
        Employee.create!(valid_attributes.merge(email: "USER@ACME.COM"))
        duplicate_employee = Employee.new(valid_attributes.merge(email: "user@acme.com", employee_number: "EMP-000002"))

        expect(duplicate_employee).not_to be_valid
        expect(duplicate_employee.errors[:email]).to include("has already been taken")
      end
    end

    context "status enum behavior" do
      it "allows active status" do
        subject.status = "active"
        expect(subject).to be_valid
        expect(subject.active?).to be true
      end

      it "allows inactive status" do
        subject.status = "inactive"
        expect(subject).to be_valid
        expect(subject.inactive?).to be true
      end

      it "raises ArgumentError when assigned an invalid status value" do
        expect { subject.status = "terminated" }.to raise_error(ArgumentError, /'terminated' is not a valid status/)
      end
    end
  end

  describe "Attribute Normalization" do
    it "downcases and strips email before validation" do
      employee = Employee.new(valid_attributes.merge(email: "  RAHUL.SHARMA@ACME.COM  "))
      employee.valid?
      expect(employee.email).to eq("rahul.sharma@acme.com")
    end

    it "uppercases and strips employee_number before validation" do
      employee = Employee.new(valid_attributes.merge(employee_number: "  emp-000001  "))
      employee.valid?
      expect(employee.employee_number).to eq("EMP-000001")
    end

    it "strips leading/trailing whitespace from first_name and last_name" do
      employee = Employee.new(valid_attributes.merge(first_name: "  Rahul  ", last_name: "  Sharma  "))
      employee.valid?
      expect(employee.first_name).to eq("Rahul")
      expect(employee.last_name).to eq("Sharma")
    end
  end

  describe "Database Constraint Consistency" do
    it "triggers database unique index constraint even if validation is bypassed for duplicate email" do
      Employee.create!(valid_attributes.merge(email: "user@acme.com"))
      duplicate = Employee.new(valid_attributes.merge(employee_number: "EMP-999", email: "USER@ACME.COM"))
      
      # When validation runs, email is normalized to "user@acme.com", matching the DB record
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "triggers database unique index constraint even if validation is bypassed for duplicate employee_number" do
      Employee.create!(valid_attributes.merge(employee_number: "EMP-100"))
      duplicate = Employee.new(valid_attributes.merge(employee_number: "emp-100", email: "other@acme.com"))

      # When validation runs, employee_number is normalized to "EMP-100", matching the DB record
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "Persistence" do
    it "persists a valid employee to the database and retrieves it" do
      saved_employee = Employee.create!(valid_attributes)
      expect(saved_employee.persisted?).to be true

      found_employee = Employee.find(saved_employee.id)
      expect(found_employee.employee_number).to eq("EMP-000001")
      expect(found_employee.first_name).to eq("Rahul")
      expect(found_employee.last_name).to eq("Sharma")
      expect(found_employee.email).to eq("rahul.sharma@acme.com")
      expect(found_employee.status).to eq("active")
    end
  end
end
