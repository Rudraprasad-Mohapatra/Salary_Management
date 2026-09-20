class Employee < ApplicationRecord
  enum :status, { active: "active", inactive: "inactive" }, default: "active"

  before_validation :normalize_attributes
  before_save :normalize_attributes

  validates :employee_number, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :country, presence: true
  validates :department, presence: true
  validates :job_title, presence: true
  validates :employment_type, presence: true
  validates :status, presence: true, inclusion: { in: %w[active inactive] }

  private

  def normalize_attributes
    self.email = email.strip.downcase if email.present?
    self.employee_number = employee_number.strip.upcase if employee_number.present?
    self.first_name = first_name.strip if first_name.present?
    self.last_name = last_name.strip if last_name.present?
  end
end
