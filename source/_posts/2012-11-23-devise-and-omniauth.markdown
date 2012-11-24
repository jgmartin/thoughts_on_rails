---
layout: post
title: "devise and omniauth"
date: 2012-11-23 21:36
comments: true
categories: 
---

One of the great things about [Devise](https://github.com/plataformatec/devise) is how easy it is to add [Omniauth](https://github.com/intridea/omniauth) support.  Omniauth is a library that standardizes authentication for a wide variety of services.  Services are supported via strategies, which are implemented as Rack middleware and distributed as gems.

You'll need to have Devise set up with a User model in order to begin.  You can find instructions [here](https://github.com/plataformatec/devise#getting-started) if necessary.  You're also going to need to get signed up with whatever provider you choose to use.  Once you're registered and have your credentials, you can actually get to work.

<!--more-->

- Add the strategy gem to your Gemfile
{% codeblock /Gemfile lang:ruby %}
gem 'omniauth-github'
{% endcodeblock %}
There is an established convention when it comes to naming the strategy gems, where the format is "omniauth-#{provider}".

- Add the Devise option :omniauthable to your User model
{% codeblock app/models/user.rb %}
class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable
{% endcodeblock %}

- Edit the Devise config file with your credentials
{% codeblock /config/initializers/devise.rb %}
config.omniauth :github, 'APP_ID', 'APP_SECRET', :scope => 'user,public_repo'
{% endcodeblock %}
Of course you'll probably want to store those credentials somewhere more secure, like an environment variable or another config file that isn't checked in to version control.

- Generate a migration to add the provider and uid columns to the User model
{% codeblock command line %}
rails g migration AddOauthToUsers provider:string, uid:string
rake db:migrate
{% endcodeblock %}

- You'll want to be able to mass-assign the provider and uid
{% codeblock app/models/user.rb %}
class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :provider, :uid
{% endcodeblock %}

- Next we're going to need a controller action and route to handle the callback from the provider
{% codeblock /app/controllers/omniauth_callbacks_controller.rb %}
class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def github
    user = User.find_for_oauth(request.env["omniauth.auth"])

    if user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Github"
      sign_in_and_redirect user, :event => :authentication
    else
      session["devise.github_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
{% endcodeblock %}
{% codeblock config/routes.rb %}
#devise_for :users
devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
{% endcodeblock %}
Note that this controller inherits from Devise::OmniauthCallbacksController.  All we need to do is implement a method with the name of the strategy we are responding to.  Within this method, we call a class method on the User model (which we'll define in a moment) that will find or create a User from the API response.

- Define Authentication::ActiveRecordHelpers and include it in User
{% codeblock /app/domain/authentication/active_record_helpers.rb %}
module Authentication
  module ActiveRecordHelpers

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def find_for_oauth(auth)
        record = where(provider: auth.provider, uid: auth.uid.to_s).first
        record || create(provider: auth.provider, uid: auth.uid, email: auth.info.email, password: Devise.friendly_token[0,20])
      end
    end
  end
end
{% endcodeblock %} 
{% codeblock /app/models/user.rb %}
class User < ActiveRecord::Base

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :provider, :uid

  include Authentication::ActiveRecordHelpers
{% endcodeblock %}

- Finally, provide a sign in link
{% codeblock view lang:ruby %}
= link_to 'Sign in with Github', user_omniauth_authorize_path(:github)
{% endcodeblock %}

That's all there is to it.  The first time you click on the link you will be redirected to the provider to authenticate, and a new User database record will be created during the callback.  For subsequent logins, the user is just retrieved from the database.

One thing to watch out for is the callback URL specified in the provider's application configuration.  You may have to set this to 'http://localhost:3000' for development purposes.  For Github, this setting is located on the account management page under 'applications'.
