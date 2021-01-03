class CreatePlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :players do |t|
      t.references :user, null: true, foreign_key: true
      t.references :club, null: false, foreign_key: true
      t.references :player_creator, foreign_key: { to_table: :players }
      t.string :affiliation_number
      t.string :gender
      t.string :first_name
      t.string :last_name
      t.string :dominant_hand
      t.date :birthdate
      t.boolean :validated
      t.timestamps
    end
  end
end
