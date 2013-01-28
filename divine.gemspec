# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'divine/version'

Gem::Specification.new do |gem|
  gem.name          = "divine"
  gem.version       = Divine::VERSION
  gem.authors       = ["Nils Franzen"]
  gem.email         = ["nils@franzens.org"]
  gem.description   = %q{A simple data serialization generator for java, ruby and javascript}
  gem.summary       = %q{A simple data serialization generator for java, ruby and javascript}
  gem.homepage      = "https://github.com/franzen/babelphish"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency(%q<docile>, [">= 1.0.0"])
  gem.add_dependency(%q<erubis>, [">= 2.7.0"])
  gem.add_dependency(%q<ruby-graphviz>, [">= 1.0.8"])
end
