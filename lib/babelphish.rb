require 'erubis'
require 'docile'

require "babelphish/version"
require "babelphish/dsl"
require "babelphish/code_generators/code_generator"
require "babelphish/code_generators/ruby"

module Babelphish
end

#
# Toplevel definition of 'struct'
#
def struct(name, version=1, &block)
  puts "struct #{name}"
  builder = Babelphish::StructBuilder.new(name, version) # Defined in babelphish/dsl.rb
  ::Docile.dsl_eval(builder, &block)
  builder
end
