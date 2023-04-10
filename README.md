# Quo Vadis

Multifactor authentication for your Rails 6 or Rails 7 app.

Designed in accordance with the [OWASP Application Security Verification Standard](https://owasp.org/www-project-application-security-verification-standard/) and relevant [OWASP Cheatsheets](https://cheatsheetseries.owasp.org).

Simple to integrate into your application.  The main task is customising the example views' markup to match your look-and-feel.


## Features

### General features

- Works with any model, e.g. `User` or `Person`.
- Works with any identifier, e.g. `:username` or `:email`.
- Minimal footprint in your models and controllers.
- Does not touch your existing database tables.
- Secrets (password, TOTP secret, 2FA recovery codes) are encrypted at rest.

### Authentication features

- Authentication by password.
- Two-factor authentication (2FA) by TOTP with recovery codes as a backup factor.  Can be optional or mandatory.
- Change password.
- Reset password.
- Account confirmation (a.k.a. email verification) (optional).
- Tokens (account confirmation, password reset), TOTPs, and recovery codes are all one-time-only.
- Sessions expired after lifetime or idle time exceeded.
- Session replaced after any privilege change.
- View active sessions, log out of any of them.
- Email-notifications of updates to authentication details.
- Audit trail.


## Installation

Add the gem to your Gemfile:

```ruby
bundle add 'quo_vadis'
```

Next, add the database tables:

```
rails quo_vadis:install:migrations && rails db:migrate
```

All the database tables are prefixed with `qv_`.

Finally, copy the example views across:

```
rails generate quo_vadis:install
```


## Usage


### Model

Your model must have an `:email` attribute.  All authentication-related emails will be sent to this address.

Your model must have an identifier, e.g. `:email` (default) or `:username`, with a uniqueness validation.

All you need do is add a call to `authenticates`, somewhere after your identifier's uniqueness validation.

For example, let's say you have a `User` model and the identifier is `:email`:

```ruby
class User < ApplicationRecord
  validates :email, uniqueness: {case_sensitive: false}
  authenticates
end
```

If instead you had a `Person` model with a `:username` identifier:

```ruby
class Person < ApplicationRecord
  validates :username, uniqueness: {case_sensitive: false}
  authenticates identifier: :username
end
```

You can create and update your models as before.  When you want to set a password for the first time, just include `:password` and, optionally, `:password_confirmation` in the attributes to `#create` or `#update`.

If you want to change an existing password, use the Change Password feature (see below).  If you update a model (that already has a password) with a `:password` attribute, it will raise a `QuoVadis::PasswordExistsError`.

The minimum password length is configured by `QuoVadis.password_minimum_length` (12 by default).


### Controllers

You can use these methods in your controllers.

__`require_password_authentication`__

Use this to restrict actions to password-authenticated users.  It is aliased to `:require_authentication` for convenience.

```ruby
class FoosController < ApplicationController
  before_action :require_password_authentication
end
```

__`require_two_factor_authentication`__

Use this to restrict actions to users authenticated with both a password and a second factor.  (You do not need to use `:require_password_authentication` for these actions.)

```ruby
class BarsController < ApplicationController
  before_action :require_two_factor_authentication
end
```

__`login(model, browser_session = true)`__

To log in a user who has authenticated with a password, call `#login(model, browser_session = true, metadata: {})`.  For the `browser_session` argument, optionally pass `true` to log in for the duration of the browser session, or `false` to log in for `QuoVadis.session_lifetime` (which could be the browser session anyway).  Any metadata are stored in the log entry for the login.

__`authenticated_model`__

Call this to get the authenticated user.  Feel free to alias this to `:current_user` or set it into an `ActiveSupport::CurrentAttributes` class.

Available in controllers and views.

__`logged_in?`__

Call this to find out whether a user has authenticated with a password.

Available in controllers and views.


### Views

You can use `authenticated_model` and `logged_in?` in your views.  For example:

```erb
<% if logged_in? %>
  <%= link_to 'My profile', authenticated_model %>
<% end %>
```

In your own views, you must prefix QuoVadis's routes with `quo_vadis.`.  For example:

```ruby
link_to 'Log in', quo_vadis.login_path
```

When you are customising QuoVadis's views, you must prefix your app's routes with `main_app.`.  For example:

```ruby
link_to 'Home', main_app.root_path
```


## Features

The example views show the forms and fields you need.  You should only need to adapt the markup to suit your app's appearance.

In the snippets below we assume a `User` model whose identifier is `:email`.  You can of course use anything you like.


### Sign up

Your new user sign-up form ([example](https://github.com/airblade/quo_vadis/blob/master/test/dummy/app/views/users/new.html.erb)) must include:

- a `:password` field;
- optionally a `:password_confirmation` field;
- a field for their identifier;
- an `:email` field if the identifier is not their email.

In your controller, use the `#login` method to log in your new user.  The optional second argument sets the length of the session (defaults to the browser session) - see the description above in the Controllers section).

After logging in the user, redirect them wherever you like.  You can use `qv.path_after_signup` which resolves to the first of these routes that exists: `:after_signup`, `:after_login`, the root route.

```ruby
class UsersController < ApplicationController
  def create
    @user = User.new user_params
    if @user.save
      login @user
      redirect_to qv.path_after_signup
    else
      # ...
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
```

```ruby
# config/routes.rb
get '/dashboard', as: 'after_login'
```


### Sign up with account confirmation

Follow the steps above for sign-up.

After you have logged in the user and redirected them (to any page which requires being logged in), QuoVadis detects that they need to confirm their account.  QuoVadis emails them a 6-digit confirmation code and redirects them to the confirmation page where they can enter that code.

The confirmation code is valid for `QuoVadis.account_confirmation_token_lifetime`.

Once the user has confirmed their account, they will be redirected to `qv.path_after_signup` which resolves to the first of these routes that exists: `:after_signup`, `:after_login`, the root route.  Add whichever works best for you.

You need to write the email view ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/mailer/account_confirmation.text.erb)).  It must be in `app/views/quo_vadis/mailer/account_confirmation.{text,html}.erb` and output the `@otp` variable.  See the Configuration section below for how to set QuoVadis's emails' from addresses, headers, etc.

Now write the confirmation page where the user types in the confirmation code from the email ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/confirmations/new.html.erb)).  It must be in `app/views/quo_vadis/confirmations/new.html.:format` and must POST the `otp` field to `confirm_path`.  You can provide a button to send a new confirmation code (perhaps the original email didn't arrive, or the user didn't have time to act on it before it expired) – it should POST to `send_confirmation_path`.

If the user closes their browser after signing up but before they have confirmed their account, when they next access a logged-in page they will be sent a new confirmation code and redirected to the confirmation page, as if they had just signed up.


### Login

Use `before_action :require_password_authentication` or `before_action :require_authentication` in your controllers.

Write the login view ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/sessions/new.html.erb)).  Your login form must be in `app/views/quo_vadis/sessions/new.html.:format`.  Note it must capture the user's identifier (not email, unless the identifier is email).

If you include a `remember` checkbox in your login form:

- if the user checks it, they will be logged in for `QuoVadis.session_lifetime`;
- if the user does not check it, they will be logged in for the browser session.

If you do not include a `remember` checkbox, the user will be logged in for `QuoVadis.session_lifetime`.

After authenticating the user will be redirected to the first of these that exists:

- the page they tried to view before they were redirected to the login page;
- a route named `after_login`, if any;
- your root route.


### Two-factor authentication (2FA) or Two-step verification (2SV)

If you do not want 2FA at all, set `QuoVadis.two_factor_authentication_mandatory false` in your configuration and skip the rest of this section.

If you do want 2FA, you can choose whether it is mandatory or optional for your users by setting `QuoVadis.two_factor_authentication_mandatory <true|false>` in your configuration.

Use `before_action :require_two_factor_authentication` in your controllers (which supersedes `:require_password_authentication`).  This will require the user, after authenticating with their password, to authenticate with 2FA – when 2FA is mandatory, or when it is optional and the user has set up 2FA.

Here's the workflow for a user setting up optional 2FA:

1. User visits their 2FA overview page.
2. [2FA overview page] User clicks a link to set up 2FA (TOTP for now).
3. [TOTP setup page] User scans the QR code with their authenticator and enters the 6-digit one-time password.
4. QuoVadis verifies the one-time password, generates 5 backup recovery codes, and redirects the user to the recovery codes page (or back to step 3 if the OTP is invalid).
5. [Recovery code page] User views and hopefully saves their 5 recovery codes.

When 2FA is mandatory the workflow starts automatically at step 3 after password authentication.

In your views, have a link where users can manage their 2FA:

```ruby
link_to '2FA', quo_vadis.twofa_path
```

Write the 2FA overview page ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/twofas/show.html.erb)).  It must be in `app/views/quo_vadis/twofas/show.html.:format`.  This page allows the user to set up 2FA, deactivate or reset it, and generate new recovery codes.

Next, write the TOTP setup page ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/totps/new.html.erb)).  It must be in `app/views/quo_vadis/totps/new.html.:format`.  This page shows the user a QR code (and the key as text) which they scan with their authenticator.

Next, write the recovery codes page ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/recovery_codes/index.html.erb)).  It must be in `app/views/quo_vadis/recovery_codes/index.html.:format`.  This shows the recovery codes immediately after TOTP is setup, and immediately after generating fresh recovery codes, but not otherwise.

Next, write the TOTP challenge page where a user inputs their 6-digit TOTP ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/totps/challenge.html.erb)).  It must be in `app/views/quo_vadis/totps/challenge.html.:format`.  It's a good idea to link to the recovery code page (`challenge_recovery_codes_path`) for any user who has lost their authenticator.

Finally, write the recovery code challenge page where a user inputs one of their recovery codes ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/recovery_codes/challenge.html.erb)).  It must be in `app/views/quo_vadis/recovery_codes/challenge.html.:format`.  A recovery code can only be used once, and using one deactivates TOTP – so the user will have to set it up again next time.


### Change password

To change their password, the user must provide their current one as well as the new one.

Write the change-password form ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/passwords/edit.html.erb)).  It must be in `app/views/quo_vadis/passwords/edit.html.:format`.

After the password has been changed, the user is redirected to the first of:

- your route named `:after_password_change`, if any;
- your root route.

A successful password change logs out any other sessions the user has (e.g. on other devices).


### Reset password

The user can reset their password if they lose it.  The flow is:

1. [Request password-reset page] User enters their identifier (not their email unless the identifier is email).
2. QuoVadis emails the user a link.  The link is valid for `QuoVadis.password_reset_token_lifetime`.
3. [The email] The user clicks the link.
4. [Password-reset confirmation page] The user enters their new password and clicks a button.
5. QuoVadis sets the user's password and logs them in.

First, write the page where the user requests a password-reset ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/password_resets/new.html.erb)).  It must be in `app/views/quo_vadis/password_resets/new.html.:format`.  Note it must capture the user's identifier (not email, unless the identifier is email).

See the Configuration section below for how to set QuoVadis's emails' from addresses, headers, etc.

Now write the page to where the user is redirected while they wait for the email ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/password_resets/index.html.erb)).  It must be in `app/views/quo_vadis/password_resets/index.html.:format`.

It's a good idea for that page to link to `new_password_reset_path` where the user can request another email if need be.

Now write the email view ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/mailer/reset_password.text.erb)).  It must be in `app/views/quo_vadis/mailer/reset_password.{text,html}.erb` and output the `@url` variable.

Next, write the page to which the link in the email points ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/password_resets/edit.html.erb)).  It must be in `app/views/quo_vadis/password_resets/edit.html.:format`.

After the user has reset their password, they will be logged in and redirected to the first of these that exists:

- a route named `:after_login`;
- your root route.


### Sessions

A logged-in session lasts for either the browser session or `QuoVadis.session_lifetime`.  As well as having a lifetime, a session will also expire after it has been inactive for `QuoVadis.session_idle_timeout`.

A user can view their active sessions and log out of any of them.

Write the view showing the sessions ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/sessions/index.html.erb)).  It must be in `app/views/quo_vadis/sessions/index.html.:format`.


### Audit trail

An audit trail is kept of authentication events.  You can see the full list in the [`Log`](https://github.com/airblade/quo_vadis/blob/master/app/models/quo_vadis/log.rb) class.

Write the view showing the events ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/logs/index.html.erb)).  It must be in `app/views/quo_vadis/logs/index.html.:format`.


### Notifications

QuoVadis notifies users by email whenever their authentication details are changed or something suspicious happens.

Write the corresponding mailer views:

- change of email ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/mailer/email_change_notification.text.erb))
- change of identifier (unless the identifier is email) ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/mailer/identifier_change_notification.text.erb))
- change of password ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/mailer/password_change_notification.text.erb))
- reset of password ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/mailer/password_reset_notification.text.erb))
- TOTP setup ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/mailer/totp_setup_notification.text.erb))
- TOTP code used a second time ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/mailer/totp_reuse_notification.text.erb))
- 2FA deactivated ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/mailer/twofa_deactivated_notification.text.erb))
- recovery codes generated ([example](https://github.com/airblade/quo_vadis/blob/master/app/views/quo_vadis/mailer/recovery_codes_generation_notification.text.erb))

They must be in `app/views/quo_vadis/mailer/NAME.{text,html}.erb`.


### Revocation

You can revoke a user's access by calling `#revoke_authentication_credentials` on the model instance.  This deletes the user's password, TOTP credential, recovery codes, and active sessions.  Their authentication logs, or audit trail, are preserved.


## Configuration

This is QuoVadis' [default configuration](https://github.com/airblade/quo_vadis/blob/master/lib/quo_vadis/defaults.rb):

```ruby
QuoVadis.configure do
  password_minimum_length               12
  mask_ips                              false
  cookie_name                           (Rails.env.production? ? '__Host-qv' : 'qv')
  session_lifetime                      :session
  session_lifetime_extend_to_end_of_day false
  session_idle_timeout                  :lifetime
  password_reset_token_lifetime         10.minutes
  accounts_require_confirmation         false
  account_confirmation_token_lifetime   10.minutes
  mail_headers                          ({ from: 'Example App <support@example.com>' })
  enqueue_transactional_emails          true
  app_name                              Rails.app_class.to_s.deconstantize  # for the TOTP QR code
  two_factor_authentication_mandatory   true
  mount_point                           '/'
end
```

You can override any of it with a similarly structured file in `config/initializers/quo_vadis.rb`.

Here are the options in detail:

__`password_minimum_length`__ (integer)

The minimum number of characters for a password.

__`mask_ips`__ (boolean)

Whether to mask the IP address in the sessions list and the audit trail.

Masking means setting the last octet (IPv4) or the last 80 bits (IPv6) to 0.

__`cookie_name`__ (string)

The name of the cookie QuoVadis uses to store the session identifier.  The `__Host-` prefix is [recommended](https://developer.mozilla.org/en-US/docs/Web/API/document/cookie) in an SSL environment (but cannot be used in a non-SSL environment).

__`session_lifetime`__ (`:session` | `ActiveSupport::Duration` | integer)

The lifetime of a logged-in session.  Use `:session` for the browser session, or a `Duration` or number of seconds.

__`session_lifetime_extend_to_end_of_day`__ (boolean)

Whether to extend the session's lifetime to the end of the day it will expire on.

Set `true` to reduce the chance of a user being logged out while actively using your application.

__`session_idle_timeout`__ (`:lifetime` | `ActiveSupport::Duration` | integer)

The logged-in session is expired if the user isn't seen for this `Duration` or number of seconds.  Use `:lifetime` to set the idle timeout to the session's lifetime (i.e. to turn off the idle timeout).

__`password_reset_token_lifetime`__ (`ActiveSupport::Duration` | integer)

The `Duration` or number of seconds for which a password-reset token is valid.

__`accounts_require_confirmation`__ (boolean)

Whether new users must confirm their account before they can log in.

__`account_confirmation_token_lifetime`__ (`ActiveSupport::Duration` | integer)

The `Duration` or number of seconds for which an account-confirmation token is valid.

__`mailer_superclass`__ (string)

The class from which QuoVadis's mailer inherits.

__`mail_headers`__ (hash)

Mail headers which QuoVadis' emails should have.

__`enqueue_transactional_emails`__ (boolean)

Set `true` if account-confirmation and password-reset emails should be queued for later delivery (`#deliver_later`) or `false` if they should be sent inline (`#deliver_now`).

__`app_name`__ (string)

Used in the provisioning URI for the TOTP QR code.

__`two_factor_authentication_mandatory`__ (boolean)

Whether users must set up and use a second authentication factor.

__`mount_point`__ (string)

The path prefix for QuoVadis's routes.

For example, the default login path is at `/login`.  If you set `mount_point` to `/auth`, the login path would be `/auth/login`.

#### Rails configuration

__Mailer URLs__

You must also configure the mailer host so URLs are generated correctly in emails:

```ruby
config.action_mailer.default_url_options: { host: 'example.com' }
```

__Layouts__

You can specify QuoVadis's controllers' layouts in a `#to_prepare` block in your application configuration.  For example:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.to_prepare do
      QuoVadis::ConfirmationsController.layout 'your_layout'
    end
  end
end
```

__Routes__

You can set up your post-signup, post-authentication, and post-password-change routes.  If you don't, you must have a root route.  For example:

```ruby
# config/routes.rb
get '/signups/confirmed', to: 'dashboards#show', as: 'after_signup'
get '/dashboard',         to: 'dashboards#show', as: 'after_login'
get '/profile',           to: 'profiles#show',   as: 'after_password_change'
```

### I18n

All QuoVadis' flash messages are set via [i18n](https://github.com/airblade/quo_vadis/blob/master/config/locales/quo_vadis.en.yml).

You can override any of the messages with your own locale file at `config/locales/quo_vadis.en.yml`.

If you don't want a specific flash message at all, give the key an empty value in your locale file.


## Intellectual Property

Copyright 2011-2022 Andrew Stewart (boss@airbladesoftware.com).

Released under the MIT licence.
