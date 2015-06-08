class DeployController < ApplicationController
  protect_from_forgery with: :null_session, only: [:webhook]
  def webhook
    # Super cheesy deployment system... for now
    logger.info `git pull origin master`
    logger.info `bundle install`
    logger.info `touch #{Rails.root}/tmp/restart.txt`
  end
end
