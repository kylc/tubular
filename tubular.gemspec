# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tubular/version'

Gem::Specification.new do |spec|
  spec.name          = "tubular"
  spec.version       = Tubular::VERSION
  spec.authors       = ["Kyle Cesare"]
  spec.email         = ["kcesare@gmail.com"]
  spec.description   = %q{A BitTorrent client}
  spec.summary       = %q{A BitTorrent client}
  spec.homepage      = "http://github.com/kylc/tubular"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "webmock"

  spec.add_runtime_dependency "celluloid"
  spec.add_runtime_dependency "celluloid-io"
end
