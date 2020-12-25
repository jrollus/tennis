class CreateGameSets < ActiveRecord::Migration[6.0]
  def change
    create_table :game_sets do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :set_number
      t.integer :games_1
      t.integer :games_2
    end
  end
end