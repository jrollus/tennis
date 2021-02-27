class CreateDivisions < ActiveRecord::Migration[6.0]
  def change
    create_table :divisions do |t|
      t.string :name
      t.integer :age_min
      t.integer :age_max
      t.string :gender
      t.string :age
      t.timestamps
    end
  end
end
