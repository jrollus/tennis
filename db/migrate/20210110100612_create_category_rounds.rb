class CreateCategoryRounds < ActiveRecord::Migration[6.0]
  def change
    create_table :category_rounds do |t|
      t.references :category, null: false, foreign_key: true
      t.references :round, null: false, foreign_key: true
      t.integer :points
      t.timestamps
    end
  end
end
