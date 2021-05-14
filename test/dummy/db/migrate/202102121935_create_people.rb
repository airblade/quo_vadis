class CreatePeople < ActiveRecord::Migration[6.1]
  def change
    create_table :people do |t|
      t.string :username, null: false
      t.string :email, null: false

      t.timestamps
    end
  end
end
