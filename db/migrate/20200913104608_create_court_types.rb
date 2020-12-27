class CreateCourtTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :court_types do |t|
      t.string :court_type
      t.timestamps
    end
  end
end
