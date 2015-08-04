# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'breadcrumbs_on_rails_to_gretel/version'

Gem::Specification.new do |spec|
  spec.name          = "breadcrumbs_on_rails_to_gretel"
  spec.version       = BreadcrumbsOnRailsToGretel::VERSION
  spec.authors       = ["Vicror Palomo de Castro"]
  spec.email         = ["victorpalomocastro@gmail.com"]

  spec.summary       = %q{Convert breadcrumb_on_rails to gretel}
  spec.description   = %q{Simple and smart way to change all breadcrumbs of your project from breadcrumb_on_rails to gretel}
  spec.homepage      = "https://github.com/victor95pc/breadcrumbs_on_rails_to_gretel"
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*.rb'] + Dir['lib/tasks/*.rake']
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ['lib', 'lib/tasks']

  spec.required_ruby_version = ">= 2.0.0"
  spec.add_dependency "rails", ">= 3.0.0"
  spec.add_development_dependency "ruby2ruby"
  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
