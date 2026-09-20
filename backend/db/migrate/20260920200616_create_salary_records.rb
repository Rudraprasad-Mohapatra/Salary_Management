class CreateSalaryRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :salary_records do |t|
      t.references :employee, null: false, foreign_key: true, index: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :currency, null: false
      t.date :effective_from, null: false
      t.date :effective_to

      t.timestamps
    end
  end
end
