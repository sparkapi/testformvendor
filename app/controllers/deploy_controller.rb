class DeployController < ApplicationController
  protect_from_forgery with: :null_session, only: [:webhook]
  def webhook
    # Super cheesy deployment system... for now
    if params[:ref] == "refs/heads/master" && params[:repository]["name"] == "testformvendor"
      logger.info `git pull origin master`
      logger.info `/usr/local/bin/bundle install`
      logger.info `RAILS_ENV=production /usr/local/bin/bundle exec rake assets:precompile`
      logger.info `touch #{Rails.root}/tmp/restart.txt`
    end
    render json: {}
  end
end
