class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.references :user, index: true, foreign_key: true
      t.boolean :public, null: false, default: false
      t.string :client_id
      t.string :client_secret
      t.string :redirect_uri
      t.string :provider
      t.string :issuer, default: nil
      t.string :authorization_endpoint, default: nil
      t.string :jwks_uri, default: nil
      t.string :userinfo_endpoint, default: nil

      t.timestamps null: false
    end
  end
end
