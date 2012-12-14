
require 'divine'

struct 'UnifySer' do
  #int8  :i8
  #int32 :i32
  #int16 :i16
  string :str
  #ip_number :ip
  #binary :guid
  map :map1, :int8, :int32
end

Divine::CodeGenerator.new.generate(:ruby, file: 'test_unify.rb', module: 'BabelTest', parent_class: "Object")
Divine::CodeGenerator.new.generate(:javascript, file: 'test_unify.js')
Divine::CodeGenerator.new.generate(:java, file: 'test_unify.java')

