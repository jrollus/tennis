class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.references :tournament, null: true, foreign_key: true
      t.references :interclub, null: true, foreign_key: true
      t.references :player, null: true, foreign_key: true
      t.references :court_type, null: true, foreign_key: true
      t.references :round, null: true, foreign_key: true
      t.date :date
      t.string :round
      t.string :status
      t.boolean :indoor
      t.timestamps
    end
  end
end
