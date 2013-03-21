# Quo Vadis?

Quo Vadis adds simple username/password authentication to Rails 3 applications.

Why bother with yet another authentication gem?  Well, I find all the others over-engineered.  Code should be easy to use and easy to read.  As far as I'm concerned, none of the others ticks both boxes.

Features:

* Minimal effort to add authentication to your app: get up and running in 5 minutes.
* No surprises: it does what you expect.
* Easy to customise.
* Uses BCrypt to encrypt passwords.
* Sign in, sign out, forgotten password, authenticate actions, remember user between browser sessions, user activation.
* Block accounts.
* Let you choose which model(s) to authenticate (defaults to `User`).

Forthcoming features:

* Generate the views for you (for now, copy the examples given below).
* Let you choose the identification field (currently `username`).
* HTTP basic/digest authentication (probably).
* Generate model plus migration if it doesn't exist.
* Detect presence of `has_secure_password` (see below) and adapt appropriately.

What it doesn't and won't do:

* Authorisation.
* Work outside Rails 3.
* OpenID, OAuth, LDAP, CAS, etc.
* Separate identity from authentication services (cf OmniAuth).
* Allow you to have multiple models/scope signed in simultaneously (cf Devise).
* Offer so much flexibility that it takes more than 10 minutes to wrap your head around it (cf Devise, Authlogic).


## Quick Start

If this takes you more than 5 minutes, you can have your money back ;)

Install and run the generator: add `gem 'quo_vadis'` to your Gemfile, run `bundle install`, then `rails generate quo_vadis:install [MODEL_NAME]` (where model name is optional and defaults to `User`).

Edit and run the generated migration to add the authentication columns: `rake db:migrate`.  Note the migration (currently) assumes you already have a table for your model.

In your `User` (or whichever) model, add `authenticates`:

    class User < ActiveRecord::Base
      authenticates
    end

Note Quo Vadis validates the presence and uniqueness of the username, and the presence of the password, but it's up to you to add any other validations you want.

Use `:authenticate` in a `before_filter` to protect your controllers' actions.  For example:

    class ArticlesController < ActionController::Base
      before_filter :authenticate, :except => [:index, :show]
    end

Write the sign-in view.  Your sign-in form must:

* be in `app/views/sessions/new.html.:format`
* POST the parameters `:username` and `:password` to `sign_in_url`

You have to write the view yourself because you'd inevitably want to change whatever markup I generated for you.  You can find an example in the [test app](https://github.com/airblade/quo_vadis/blob/master/test/dummy/app/views/sessions/new.html.erb).

Remember to serve your sign in form over HTTPS -- to avoid [the credentials being stolen](http://blog.jgc.org/2011/01/code-injected-to-steal-passwords-in.html).

In your layout, use `current_user` to retrieve the signed-in user; and `sign_in_path`, `sign_out_path`, and `forgotten_sign_in_path` as appropriate.  You can also use `authenticated?`.


## Forgotten Password

Here's the workflow:

1. [Sign in page] The user clicks the "I've forgotten my password" link.
2. [Forgotten password page] The user enters their username in the form and submits it.
3. Quo Vadis emails the user a message with a change-password link.  The link is valid for 3 hours.
4. [The email] The user clicks the link.
5. [Change password page] The user types in a new password and saves it.
6. Quo Vadis changes the user's password and signs the user in.

It'll take you about 5 minutes to implement this.

On your sign-in page, link to the forgotten-password view at `forgotten_sign_in_url`.

Write the forgotten-password view ([example](https://github.com/airblade/quo_vadis/blob/master/test/dummy/app/views/sessions/forgotten.html.erb)).  The form must:

* be in `app/views/sessions/forgotten.html.:format`
* POST the parameter `:username` to `forgotten_sign_in_url`

Now write the mailer view, i.e. the email which will be sent to your forgetful users ([example](https://github.com/airblade/quo_vadis/blob/master/test/dummy/app/views/quo_vadis/notifier/change_password.text.erb)).  The view must:

* be at `app/views/quo_vadis/notifier/change_password.text.erb`
* render `@url` somewhere (this is the link the user clicks to go to the change-password page)

You can also refer to `@username` in the email view.

Configure the email's from address in `config/initializers/quo_vadis.rb`.

Configure the default host so ActionMailer can generate the URL.  In `config/environments/<env>.rb`:

    config.action_mailer.default_url_options = {:host => 'yourdomain.com'}

Finally, write the change-password page ([example](https://github.com/airblade/quo_vadis/blob/master/test/dummy/app/views/sessions/edit.html.erb)).  The form must:

* be in `app/views/sessions/edit.html.:format`
* PUT the parameter `:password` to `change_password_url(params[:token])`


## Sign up (directly, without activation)

When you create a user, you need to sign them in.  Do this by calling `sign_in(user)` in your controller.  For example:

    # In your app
    class UsersController < ApplicationController
      def create
        @user = User.new params[:user]
        if @user.save
          sign_in @user    # <-- NOTE: sign in your user here
        else
          render 'new'
        end
      end
    end

The `sign_in(user)` method will redirect the user appropriately (you can configure this in `config/initializers/quo_vadis.rb`), as well as running any sign-in hook you may have defined in the initializer.


## Sign up (with activation)

To create a user who must activate their account (via email) before they can sign in, do this:

    # In your app
    class UsersController < ApplicationController
      def create
        @user = User.new_for_activation params[:user]    # <-- NOTE: different constructor
        if @user.save
          QuoVadis::SessionsController.new.invite_to_activate @user    # <-- NOTE: email user here
          redirect_to root_path, notice: "Emailed sign-in instructions to #{@user.name}"  # or whatever
        else
          render 'new'
        end
      end
    end

The user will receive an email with a link which takes them to a page (which you must write) where they can choose a username and password for themselves.  When they submit the form their new credentials are stored and they are signed in.

Here's the workflow:

1. [New user page, without username/password fields] You or user fills in and submits form.
2. [Users controller] Create user and invite to activate.  See code snippet above.
3. Quo Vadis emails the user a message with an invitation link.  The link is valid for 3 hours.
4. [The email] The user clicks the link.
5. [Invitation page] The user fills in their new username and password.
6. Quo Vadis sets the user's username and password and signs the user in.

It'll take you about 3 minutes to implement this.

Update your user controller's `create` action as above.

Write the mailer view, i.e. the email which will be sent to your new users ([example](https://github.com/airblade/quo_vadis/blob/master/test/dummy/app/views/quo_vadis/notifier/invite.text.erb)).  The view must:

* be at `app/views/quo_vadis/notifier/invite.text.erb`
* render `@url` somewhere (this is the link the user clicks to go to the invitation page)

You can also refer to `@user` in the email view, as well as any other data you pass to `invite_to_activate`.  Note that passing `:from` and/or `:subject` in the hash to `invite_to_activate` overrides the default `QuoVadis.from` and/or `QuoVadis.subject_invitation` respectively.

Configure the email's from address in `config/initializers/quo_vadis.rb` (or pass in the data hash to `invite_to_activate`).

Configure the default host so ActionMailer can generate the URL.  In `config/environments/<env>.rb`:

    config.action_mailer.default_url_options = {:host => 'yourdomain.com'}

Finally, write the invitation page ([example](https://github.com/airblade/quo_vadis/blob/master/test/dummy/app/views/sessions/invite.html.erb)).  The form must:

* be in `app/views/sessions/invite.html.:format`
* POST the parameters `:username` and `:password` to `activation_url(params[:token])`

If the token expires and you need to generate a new one, re-invite the user with: `invite_to_activate @user`.


## Customisation

You can customise the flash messages and mailer from/subject in `config/locales/quo_vadis.en.yml`.

You can customise the sign-in and sign-out redirects in `config/initializers/quo_vadis.rb`; they both default to the root route.  You can also hook into the sign-in and sign-out process if you need to run any other code.

If you want to add other session management type features, go right ahead: create a `SessionsController` as normal and carry on.

You can skip the validation of authentication attributes (password etc) by overriding `should_authenticate?` in your model.  Perhaps only some of the users should be able to sign in, so you don't want to force them to have a password.


## See also

* Rails 3 edge's [ActiveModel::SecurePassword](https://github.com/rails/rails/blob/master/activemodel/lib/active_model/secure_password.rb).  It's `has_secure_password` class method is similar to Quo Vadis's `authenticates` class method.
* [RailsCast 250: Authentication from Scratch](http://railscasts.com/episodes/250-authentication-from-scratch).


## What's up with the name?

Roman sentries used to challenge intruders with, "Halt!  Who goes there?"; quo vadis is Latin for "Who goes there?".  At least that's what my Latin teacher told us, but I was 8 years old then so I may not be remembering this entirely accurately.


## Questions, Problems, Feedback

Please use the GitHub [issue tracker](https://github.com/airblade/quo_vadis/issues) or email me.


## Intellectual property

Copyright 2011 Andy Stewart (boss@airbladesoftware.com).

Released under the MIT licence.
