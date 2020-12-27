class CreateClubs < ActiveRecord::Migration[6.0]
  def change
    create_table :clubs do |t|
      t.integer :code
      t.string :name
      t.string :address
      t.string :city
      t.string :website
      t.string :email
      t.string :phone_number
      t.timestamps
    end
  end
end
