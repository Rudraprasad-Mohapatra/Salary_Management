class SalaryRecord < ApplicationRecord
  SUPPORTED_CURRENCIES = %w[INR USD EUR GBP AUD CAD SGD AED].freeze

  belongs_to :employee

  before_validation :normalize_currency

  validates :employee, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: SUPPORTED_CURRENCIES }
  validates :effective_from, presence: true
  validate :effective_to_must_be_on_or_after_effective_from
  validate :no_overlapping_salary_periods

  private

  def normalize_currency
    self.currency = currency.strip.upcase if currency.present?
  end

  def effective_to_must_be_on_or_after_effective_from
    return unless effective_from.present? && effective_to.present?

    if effective_to < effective_from
      errors.add(:effective_to, "must be on or after effective_from")
    end
  end

  def no_overlapping_salary_periods
    return unless employee_id.present? && effective_from.present?

    scope = SalaryRecord.where(employee_id: employee_id)
    scope = scope.where.not(id: id) if persisted?

    overlapping_record = scope.find do |record|
      start_a = effective_from
      end_a = effective_to

      start_b = record.effective_from
      end_b = record.effective_to

      (end_b.nil? || start_a <= end_b) && (end_a.nil? || start_b <= end_a)
    end

    if overlapping_record
      errors.add(:base, "Salary period overlaps with an existing record")
    end
  end
end
