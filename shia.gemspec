# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shia/version'

Gem::Specification.new do |spec|
  spec.name          = 'shia'
  spec.version       = Shia::VERSION
  spec.authors       = ['Nick Thomas']
  spec.email         = ['nick.thomas@kloeckner.com']

  spec.summary       = 'JUST DO IT!'
  spec.description   = 'SHIA (or the Seamless Hive Integration Agent) is the KCI webscale cloud deployment tool'
  spec.homepage      = 'https://git.kci.rocks/nick.thomas/shia'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'TODO: your gemhost of choice'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = Dir.glob('{exe,lib,config}/**/*') + %w(README.md)
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'net-ssh', '~> 3.2'
  spec.add_dependency 'colorize', '~> 0.8.1'
  spec.add_dependency 'docker_registry2', '~> 0.3.0'
  spec.add_dependency 'rancher-api', '~> 0.5.2'

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rubocop', '~> 0.42'
  spec.add_development_dependency 'simplecov', '~> 0.12'
  spec.add_development_dependency 'webmock', '~> 2.1'
  spec.add_development_dependency 'vcr'
end
