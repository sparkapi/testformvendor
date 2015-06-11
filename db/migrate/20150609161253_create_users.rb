class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :password_digest
      t.string :email
      t.string :fullname

      t.timestamps null: false
    end
    add_index :users, :email, unique: true
  end
end
