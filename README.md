# Quo Vadis?

Quo Vadis adds simple username/password authentication to Rails 3 applications.

Features:

* Minimal effort to add authentication to your app.
* No surprises: it does what you expect.
* Easy to customise.
* Uses BCrypt to encrypt passwords.
* Sign in, sign out, authenticate actions.

Forthcoming features:

* Handle forgotten-details.
* Let you choose which model(s) to authenticate (currently `User`).
* Let you choose the identification field (currently `username`).
* Remember authenticated user across browser sessions.
* HTTP basic/digest authentication (probably).

What it doesn't and won't do:

* Authorisation.
* Sign up; that's user management, not authentication.
* Work outside Rails 3.
* OpenID, OAuth, LDAP, CAS, etc.
* Separate identity from authentication services (cf OmniAuth).
* Allow you to have multiple models/scope signed in simultaneously (cf Devise).
* Offer so much flexibility that it takes more than 10 minutes to wrap your head around it (cf Devise, Authlogic).


## Installation

Add `gem 'quo_vadis'` to your Gemfile.


## Quick start guide

Install.

Use `:authenticate` in a `before_filter` to protect your controllers' actions.  For example:

    class ArticleController < ActionController::Base
      before_filter :authenticate, :except => [:index, :show]
    end

Write sign in view.  See below.

Assuming you already have a User model, add `authenticates`:

    class User < ActiveRecord::Base
      authenticates
    end

Generate, edit and run migration to add authentication columns: `rails generate quo_vadis && rake db:migrate`.



## Detailed usage

1.  Add gem to Gemfile.

This adds to your `ApplicationController` a `current_user` helper method and makes available an `authenticate` method which you can use to protect actions requiring authentication.  For example:

    class ArticleController < ApplicationController
      before_filter :authenticate, :except => [:index, :show]
    end

2.  Create views for your sign-in form and your fogotten-sign-in-details form.  Writing them yourself doesn't take long and ensures they use the markup you want, not the markup I like.

Your sign-in form must:
* be in `app/views/sessions/new.html.{haml|erb}`
* post the parameters `:username` and `:password` to `sign_in_url`

3.  Set the URLs to which to redirect the user upon successful sign in, sign out, and reminder.

By default when a user signs in successfully they are redirected to `root_url`.  To change this, create a sessions controller of your own and override the `signed_in_url` method.  For example:

    class SessionsController < ActionController::Base

      private

      # Returns the path to redirect the user to after successful sign-in.
      def signed_in_url
        user.admin? ? admin_url : root_url
      end
    end

Do the same for `signed_out_url` (which defaults to `root_url`) and `reminded_url` (same default).

You can also hook into the sign in/out process to run arbitrary code.  Just define any of the following methods: `on_successful_sign_in`, `on_failed_sign_in`, `on_sign_out`, `on_forgotten_details`.  For example:

    class SessionsController < ActionController::Base

      private

      def on_failed_sign_in
        # log IP address
      end
    end

4.  Customise the flash mesages displayed on sign in, sign out, etc.

TODO: can we generate the locales file automatically?

See `config/locales/quo_vadis.en.yml`.

5.  In your user model, `authenticates`.

    class User < ActiveRecord::Base
      authenticates
    end

TODO: description

TODO: migration


## What's up with the name?

According to my Latin teacher, Roman sentries used to challenge intruders with, "Halt!  Who goes there?".  Quo vadis is Latin for "Who goes there?".  But I was 8 when we had that lesson so I may have got all this completely wrong.
