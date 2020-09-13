class CreateTournamentCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :category
      t.string :gender
      t.integer :points_1_128
      t.integer :points_1_64
      t.integer :points_1_32
      t.integer :points_1_16
      t.integer :points_1_8
      t.integer :points_1_4
      t.integer :points_1_2
      t.integer :final_points
      t.integer :winner_points

      t.timestamps
    end
  end
end
