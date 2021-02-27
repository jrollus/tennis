class CreateInterclubs < ActiveRecord::Migration[6.0]
  def change
    create_table :interclubs do |t|
      t.references :division, null: false, foreign_key: true
    end
  end
end
