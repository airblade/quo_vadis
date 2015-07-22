# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'quo_vadis/version'

Gem::Specification.new do |s|
  s.name        = 'quo_vadis'
  s.version     = QuoVadis::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Andy Stewart']
  s.email       = ['boss@airbladesoftware.com']
  s.homepage    = 'https://github.com/airblade/quo_vadis'
  s.summary     = 'Simple username/password authentication for Rails 3.'
  s.description = s.summary

  s.rubyforge_project = 'quo_vadis'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'rails',       '~> 3.0.4'
  s.add_dependency 'bcrypt-ruby', '~> 3.0.0'

  # s.add_development_dependency 'rails', '~> 3.0.4'  # so we can test CSRF protection
  s.add_development_dependency 'sqlite3-ruby'
  s.add_development_dependency 'capybara', '~>1.1'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'rake'
end
