require 'erubis'
require 'docile'

require "divine/version"
require "divine/dsl"
require "divine/code_generators/code_generator"
require "divine/code_generators/ruby"
require "divine/code_generators/java"
require "divine/code_generators/javascript"
require "divine/code_generators/csharp"
require "divine/graph_generator/graph_generator"

module Divine
end

#
# start to build struct
#
def struct(name, properties=nil, &block)
  #puts "struct #{name}"
  builder = Divine::StructBuilder.new(name, properties) # Defined in divine/dsl.rb
  ::Docile.dsl_eval(builder, &block)
  builder
end
