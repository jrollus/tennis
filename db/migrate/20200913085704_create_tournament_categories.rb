class CreateTournamentCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :category
      t.integer :age_min
      t.integer :age_max
      t.string :gender
      t.string :age
      t.string :c_type
      t.timestamps
    end
  end
end
