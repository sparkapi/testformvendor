class Provider < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true
  validates :client_id, presence: true
  validates :redirect_uri, presence: true
  validates :redirect_uri, format: { with: URI.regexp }, if: Proc.new { |a| a.redirect_uri.present? }
end
