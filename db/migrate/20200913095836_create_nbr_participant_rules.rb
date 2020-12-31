class CreateNbrParticipantRules < ActiveRecord::Migration[6.0]
  def change
    create_table :nbr_participant_rules do |t|
      t.integer :lower_bound
      t.integer :upper_bound
      t.float :weight
      t.timestamps
    end
  end
end
