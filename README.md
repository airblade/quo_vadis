# Quo Vadis?

Quo Vadis adds simple username/password authentication to Rails 3 applications.

Features:

* Minimal effort to add authentication to your app: get up and running in 5 minutes.
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
* Generate (User) model plus migration if it doesn't exist.
* Detect presence of `has_secure_password` (see below) and adapt appropriately.

What it doesn't and won't do:

* Authorisation.
* Sign up; that's user management, not authentication.
* Work outside Rails 3.
* OpenID, OAuth, LDAP, CAS, etc.
* Separate identity from authentication services (cf OmniAuth).
* Allow you to have multiple models/scope signed in simultaneously (cf Devise).
* Offer so much flexibility that it takes more than 10 minutes to wrap your head around it (cf Devise, Authlogic).


## Quick Start

Install and run the generator: add `gem 'quo_vadis'` to your Gemfile and run `rails generate quo_vadis:install`.

Edit and run the generated migration to add authentication columns: `rake db:migrate`.  Note the migration (currently) assumes you already have a `User` model.

In your `User` model, add `authenticates`:

    class User < ActiveRecord::Base
      authenticates
    end

Note Quo Vadis validates the presence of the password, but it's up to you to add any other validations you want.

Use `:authenticate` in a `before_filter` to protect your controllers' actions.  For example:

    class ArticleController < ActionController::Base
      before_filter :authenticate, :except => [:index, :show]
    end

Write the sign-in view.  Your sign-in form must:

* be in `app/views/sessions/new.html.:format`
* post the parameters `:username` and `:password` to `sign_in_url`

In your layout, use `current_user` to retrieve the signed-in user, and `sign_in_path` and `sign_out_path` as appropriate.


## Customisation

You can customise the flash messages in `config/locales/quo_vadis.en.yml`.

You can customise the sign-in and sign-out redirects in `config/initializers/quo_vadis.rb`; they both default to the root route.  You can also hook into the sign-in and sign-out process if you need to run any other code.

If you want to add other session management type features, go right ahead: create a `SessionsController` as normal and carry on.


## See also

* Rails 3 edge's [ActiveModel::SecurePassword](https://github.com/rails/rails/blob/master/activemodel/lib/active_model/secure_password.rb).  It's `has_secure_password` class method is similar to Quo Vadis's `authenticates` class method.
* [RailsCast 250: Authentication from Scratch](http://railscasts.com/episodes/250-authentication-from-scratch).


## What's up with the name?

Roman sentries used to challenge intruders with, "Halt!  Who goes there?"; quo vadis is Latin for "Who goes there?".  At least that's what my Latin teacher told us, but I was 8 years old then so I may not be remembering this entirely accurately.
