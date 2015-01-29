# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "tm_bundle_support"
  spec.version       = "0.0.1"
  spec.authors       = ["Tōnis Simo"]
  spec.email         = ["anton.estum@gmail.com"]
  spec.summary       = %q{Textmate Bundle Support Tools}
  spec.description   = %q{Helpful ruby scripts for textmate bundle developers.}
  spec.homepage      = "http://github.com/estum/tm_bundle_support"
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*.rb'] + Dir['bin/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.required_ruby_version = ">= 2.1"
  
  spec.add_runtime_dependency "activesupport", "~> 4.1", ">= 4.2"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
