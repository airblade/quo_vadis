# CHANGELOG


## HEAD


## Unrelease

* Rename `account_confirmation_token_lifetime` to `account_confirmation_otp_lifetime`.
* Use OTP instead of link for account confirmation.


## 2.1.11 (14 September 2022)

* Introduce common controller superclass.


## 2.1.10 (14 September 2022)

* Enable configuration of mailer superclass.


## 2.1.9 (13 September 2022)

* Enable code to be run after sign up.


## 2.1.8 (18 June 2022)

* Extract convenience method for has authentication account.
* Only authenticating models react to email change.


## 2.1.7 (30 May 2022)

* Use SHA256 digest for encryption.
* Use <time> element in logs view.


## 2.1.6 (30 May 2022)

* Fix typo in session scope.


## 2.1.5 (27 May 2022)

* Order sessions list and display more information.
* Set status 303 See Other on destroy redirects.
* Streamline bundler instructions.


## 2.1.4 (2 October 2021)

* Allow metadata for login log.


## 2.1.3 (30 September 2021)

* Pass IP and timestamp as parameters to mailer.


## 2.1.2 (30 September 2021)

* Delete existing recovery codes when generating new ones.


## 2.1.1 (8 July 2021)

* Remove unnecessary route names.
* Add user revocation.
* Ensure password is only updated via #change or #reset.
* Move views into gem's app/views/ directory.


## 2.1.0 (25 June 2021)

* Do not require password on create.
* Fix incorrect assignment of built association.
* Add i18n translations for log actions.
* Use model instance in change-password form.
* Ensure password-reset flash notice not displayed when emailed link is clicked.
* Use model instance in password-reset form.
* Give no indication of unknown account on request of password reset email.
* Use 422 status code for form submission error responses.
* Make default cookie name depend on Rails environment.


## 2.0.2 (24 May 2021)

* Account confirmation: enable updating of email address.
* Account confirmation: enable direct resending of email.
* Log unknown identifier in metadata.


## 2.0.1 (18 May 2021)

* Remove Gemfile.lock from repo.
* Move runtime dependencies into gemspec.
* Include test files in gem package (so views can be installed).


## 2.0.0 (14 May 2021)

* Total rewrite from scratch.


## 1.4.0 (12 October 2016)

* Internationalise emails' subject lines.


## 1.3.2 (22 July 2015)

* Loosen Rails dependency.
* Remove unnecessary code from test app.


## 1.3.1 (22 July 2015)

* Prefer an instance method to prepare for activation.


## 1.3.0 (23 May 2013)

* Validate username's uniqueness case-insensitively.


## 1.2.3 (21 March 2013)

* Ability to override the activation email's from and subject.


## 1.2.2 (20 March 2013)

* Enable form validation errors in activation form.
* Increase time limit for password reset / activation to 24hr.


## 1.2.1 (15 August 2012)

* Ignore blank usenames when authenticating.


## 1.2.0 (18 July 2012)

* User activation.


## 1.1.2 (7 February 2012)

* Replace ActiveSupport::SecureRandom with SecureRandom.


## 1.1.1 (18 October 2011)

* Only change password when a non-blank value is given.
* Add `authenticated?` helper method.


## 1.1.0 (7 October 2011)

* Correctly handle blank username in password reset.
* Allow configuration of cookie domain.
* Pass controller to signed_{in,out}_url to allow routes with options/parameters.
* Fix bug where `signed_in_url` config setting was overwritten.
* Harmonise bcrypt-ruby dependency with ActiveModel::SecurePassword.
* Allow conditional validation of authentication attributes.
* Allow authentication of any model.


## 1.0.7 (4 October 2011)

* Allow more recent bcrypt-ruby versions.


## 1.0.6 (4 October 2011)

* Fix sign-in hook when called outside Quo Vadis.


## 1.0.5 (23 February 2011)

* Support blocking of sign-in process.


## 1.0.4 (22 February 2011)

* Work with Rails' improved CSRF protection.
* Prevent session fixation attacks.


## 1.0.3 (7 February 2011)

* Remember user between browser sessions.


## 1.0.2 (27 January 2011)

* Forgotten-password functionality.


## 1.0.1 (26 January 2011)

* Configurable layout.
* Make flash messages optional.


## 1.0.0 (25 January 2011)

* Sign in.
* Sign out.
* Authenticate actions.
* Remember URL user wants to view.
* Hooks for sign in, sign out, failed sign in.
