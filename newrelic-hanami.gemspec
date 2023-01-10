# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'newrelic-hanami/version'

Gem::Specification.new do |spec|
  spec.name          = 'newrelic-hanami'
  spec.version       = NewRelic::Hanami::VERSION
  spec.authors       = ['Yuri Artemev']
  spec.email         = ['i@artemeff.com']

  spec.summary       = 'Gem for connecting NewRelic and Hanami'
  spec.homepage      = 'https://github.com/artemeff/newrelic-hanami'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.3' # lowest common limit of newrelic_rpm and hanami-controller

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'hanami-controller', '~> 2.0.0.alpha'
  spec.add_runtime_dependency 'newrelic_rpm'

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'

  # for RSpecs against sample Hanami apps (in spec/support/apps)
  spec.add_development_dependency 'hanami-router', '~> 2.0.0.alpha'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'webrick'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
