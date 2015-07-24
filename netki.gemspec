# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'netki/version'

Gem::Specification.new do |spec|
  spec.name          = "netki"
  spec.version       = Netki::VERSION
  spec.authors       = ["Matt David"]
  spec.email         = ["opensource@netki.com"]

  spec.summary       = %q{Netki module that provides access to the Netki Wallet Name Partner API}
  spec.description   = %q{Netki module that provides access to the Netki Wallet Name Partner API}
  spec.homepage      = "https://github.com/netkicorp/ruby-partner-client"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "httpclient"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "test-unit-mock"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "webmock"
end
