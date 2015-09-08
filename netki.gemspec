# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "netki-tether"
  spec.version       = "0.0.5"
  spec.licenses      = ['BSD-3-Clause']
  spec.authors       = ["Matt David", "Whit Jackson"]
  spec.email         = ["opensource@netki.com"]

  spec.summary       = %q{Netki Public Lookup API}
  spec.description   = %q{Netki module that provides access to the Netki Lookup API}
  spec.homepage      = "https://github.com/whitj00/ruby-lookup-client"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "httpclient", "~> 2.6"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit", "~> 3.1"
  spec.add_development_dependency "test-unit-mock", "~> 0.3"
  spec.add_development_dependency "mocha", "~> 1.1"
  spec.add_development_dependency "webmock", "~> 1.21"
end
