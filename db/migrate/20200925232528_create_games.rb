class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.references :tournament, null: false, foreign_key: true
      t.date :date
      t.string :round
      t.string :status
      t.string :court_type
      t.boolean :indoor
     
      t.timestamps
    end
  end
end
