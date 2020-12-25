class CreateTieBreak < ActiveRecord::Migration[6.0]
  def change
    create_table :tie_breaks do |t|
      t.references :game_set, null: false, foreign_key: true
      t.integer :points_1
      t.integer :points_2
    end
  end
end
