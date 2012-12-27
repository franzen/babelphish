require 'erubis'
require 'docile'

require_relative "divine/version"
require_relative "divine/dsl"
require_relative "divine/code_generators/code_generator"
require_relative "divine/code_generators/ruby"
require_relative "divine/code_generators/java"
require_relative "divine/code_generators/javascript"

module Divine
end

#
# Toplevel definition of struct'
#
def struct(name, properties=nil, &block)
  #puts "struct #{name}"
  builder = Divine::StructBuilder.new(name, properties) # Defined in divine/dsl.rb
  ::Docile.dsl_eval(builder, &block)
  builder
end
