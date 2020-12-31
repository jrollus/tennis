class CreateTournaments < ActiveRecord::Migration[6.0]
  def change
    create_table :tournaments do |t|
      t.references :club, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.integer :nbr_participants
      t.timestamps
    end
  end
end
