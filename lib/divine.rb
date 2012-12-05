require 'erubis'
require 'docile'

require "divine/version"
require "divine/dsl"
require "divine/code_generators/code_generator"
require "divine/code_generators/ruby"
require "divine/code_generators/java"
require "divine/code_generators/javascript"

module Babelphish
end

#
# Toplevel definition of 'struct'
#
def struct(name, version=1, &block)
  puts "struct #{name}"
  builder = Babelphish::StructBuilder.new(name, version) # Defined in divine/dsl.rb
  ::Docile.dsl_eval(builder, &block)
  builder
end
