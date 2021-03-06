class CreateInterclubs < ActiveRecord::Migration[6.0]
  def change
    create_table :interclubs do |t|
      t.references :division, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.timestamps
    end
  end
end
