# frozen_string_literal: true

require_relative 'lib/quo_vadis/version'

Gem::Specification.new do |spec|
  spec.name          = 'quo_vadis'
  spec.version       = QuoVadis::VERSION
  spec.authors       = ['Andy Stewart']
  spec.email         = ['boss@airbladesoftware.com']

  spec.summary       = 'Multifactor authentication for Rails 6.'
  spec.homepage      = 'https://github.com/airblade/quo_vadis'
  spec.license       = 'MIT'

  # spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '>= 6'
  spec.add_dependency 'bcrypt', '~> 3.1.7'
end
