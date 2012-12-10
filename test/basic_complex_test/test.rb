
require 'divine'

struct 'TestBasic' do
  int8 :i8
  int16 :i16
  int32 :i32
  string :str
  ip_number :ip
  binary :guid
end

struct 'Entry' do

end


struct(:TestComplex) {
  list :list1, :int32
  list :list2, :int8
  map :map1, :int8, :int32
  map(:map2, :string) { 
    list 'Entry'
  }
}

Divine::CodeGenerator.new.generate(:ruby, file: 'test_babel.rb', module: 'BabelTest', parent_class: "Object")
Divine::CodeGenerator.new.generate(:javascript, file: 'test_babel.js')
Divine::CodeGenerator.new.generate(:java, file: 'test_babel.java')

