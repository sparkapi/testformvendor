class AddNameToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :name, :string
  end
end
