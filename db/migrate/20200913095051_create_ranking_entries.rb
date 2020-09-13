class CreateRankingEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :ranking_entries do |t|
      t.string :ranking_name
      t.integer :ranking_points

      t.timestamps
    end
  end
end
