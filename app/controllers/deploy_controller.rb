class DeployController < ApplicationController
  protect_from_forgery with: :null_session, only: [:webhook]
  def webhook
  end
end
