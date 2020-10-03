class CreatePlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :players do |t|
      t.references :club, null: false, foreign_key: true
      t.string :affilitiation_number
      t.string :gender
      t.string :first_name
      t.string :last_name
      t.string :dominant_hand
      t.date :birthdate

      t.timestamps
    end
  end
end
