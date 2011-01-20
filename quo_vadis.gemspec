# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'quo_vadis/version'

Gem::Specification.new do |s|
  s.name        = 'quo_vadis'
  s.version     = QuoVadis::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Andy Stewart']
  s.email       = ['boss@airbladesoftware.com']
  s.homepage    = ''
  s.summary     = %q{Simple authentication for Rails 3.}
  s.description = s.summary

  s.rubyforge_project = 'quo_vadis'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
