class CreateRankingHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :ranking_histories do |t|
      t.references :ranking, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :year
      t.integer :year_number
      t.date :start_date
      t.date :end_date
      t.boolean :validated
      t.integer :points, default: 0
      t.string :national_ranking
      t.timestamps
    end
  end
end
