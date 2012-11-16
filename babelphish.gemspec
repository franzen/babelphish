# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'babelphish/version'

Gem::Specification.new do |gem|
  gem.name          = "babelphish"
  gem.version       = Babelphish::VERSION
  gem.authors       = ["Nils Franzen"]
  gem.email         = ["nils@franzens.org"]
  gem.description   = %q{A simple data serialization library/generator for java, ruby and javascript}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = "https://github.com/franzen/babelphish"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
