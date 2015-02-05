# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/url_auth/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-url_auth"
  spec.version       = Rack::UrlAuth::VERSION
  spec.authors       = ["macario"]
  spec.email         = ["mail@makarius.me"]
  spec.description   = %q{Middleware for signing urls}
  spec.summary       = %q{Middleware authorizing signed urls, so they can't be tampered}
  spec.homepage      = "http://github.com/maca/rack-url_auth"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby-hmac"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
