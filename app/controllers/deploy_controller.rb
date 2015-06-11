class DeployController < ApplicationController
  protect_from_forgery with: :null_session, only: [:webhook]
  def webhook
    # Super cheesy deployment system... for now
    if params[:ref] == "refs/heads/master" && params[:repository]["name"] == "testformvendor"
      logger.info "git fetch/reset"
      logger.info `git fetch origin 2>&1`
      logger.info `git reset --hard origin/master`
      logger.info "Reset deploy to:\n" + `git log -n 1 HEAD`
      logger.info "Running bundle install"
      logger.info `bundle install --path=vendor/bundle 2>&1`
      logger.info "Running asset precompile"
      logger.info `bundle exec rake assets:precompile 2>&1`
      logger.info "Restart app"
      logger.info `touch #{Rails.root}/tmp/restart.txt`
    end
    render json: {}
  end
end
