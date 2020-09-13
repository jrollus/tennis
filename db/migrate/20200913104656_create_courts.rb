class CreateCourts < ActiveRecord::Migration[6.0]
  def change
    create_table :courts do |t|
      t.references :club, null: false, foreign_key: true
      t.boolean :indoor
      t.string :court_type
      t.boolean :light

      t.timestamps
    end
  end
end
