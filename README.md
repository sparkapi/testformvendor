# TestFormVendor
Rails app that runs the TestFormVendor.com OpenID Connect Sample app

## OpenID Connect Relying Party Walkthrough

A few files are noteworthy in checking out for wring your own RP application:

* [Main Controller](https://github.com/sparkapi/testformvendor/blob/master/app/controllers/main_controller.rb) -- Authorization Code flow happens here
* [Index View](https://github.com/sparkapi/testformvendor/blob/master/app/views/main/index.html.erb) -- Sets up the log in event for a chosen OIDC Provider
* [Callback View](https://github.com/sparkapi/testformvendor/blob/master/app/views/main/callback.html.erb) -- The callback for OIDC.  This has two separate views.  One using the javascript lib for Implicit and Hybrid flows, and one displaying server-side controller variables when using Authorization Code

## Running this app locally

* Install gems:

`$ bundle install`

* Set up the SQLite DB

`$ bundle exec rake db:migrate`

* Add a user for yourself

`$ bundle exec rake "user:create[my@email.com,My Name,passw0rd]"`

(If you do not specify a password, one will be randomly generated and printed)

* Run a local rails server

`$ bundle exec rails server`

* Point your web browser to http://localhost:3000/
* Have Fun!!!

## Submitting Patches

* Fork the [testformvendor](https://github.com/sparkapi/testformvendor) repo
* Create a feature branch in your local clone
* Submit a pull request





