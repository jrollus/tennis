class CreateGameplayers < ActiveRecord::Migration[6.0]
  def change
    create_table :game_players do |t|
      t.references :player, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.references :ranking, null: true, foreign_key: true
      t.boolean :victory
      t.boolean :validated
      t.integer :match_points_saved, default: 0
      t.timestamps
    end
  end
end
