class CreateRankingEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :rankings do |t|
      t.string :name
      t.integer :points
      t.string :r_type
      t.integer :age_min
      t.integer :age_max
      t.timestamps
    end
  end
end
