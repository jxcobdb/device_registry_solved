class CreateAssignmentHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :assignment_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :device, null: false, foreign_key: true
      t.string :action

      t.timestamps
    end
  end
end
