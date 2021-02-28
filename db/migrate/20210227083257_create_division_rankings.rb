class CreateDivisionRankings < ActiveRecord::Migration[6.0]
  def change
    create_table :division_rankings do |t|
      t.references :division, null: false, foreign_key: true
      t.references :ranking, null: false, foreign_key: true
      t.integer :points
      t.timestamps
    end
  end
end
