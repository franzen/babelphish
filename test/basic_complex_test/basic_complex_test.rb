
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

# Draw ERD for prev. structs
Divine::GraphGenerator.new.draw("test/basic_complex_test/")

if ARGV[0] == "ruby"
  Divine::CodeGenerator.new.generate(:ruby, file: 'test_babel.rb', module: 'BabelTest', parent_class: "Object", target_dir: 'test/basic_complex_test/ruby_test')
elsif ARGV[0] == "js"
  Divine::CodeGenerator.new.generate(:javascript, file: 'test_babel.js', target_dir: 'test/basic_complex_test/js_test')
elsif ARGV[0] == "java"
  Divine::CodeGenerator.new.generate(:java, file: 'test_babel.java', target_dir: 'test/basic_complex_test/java_test')
elsif ARGV[0] == "csharp"
  #Divine::CodeGenerator.new.generate(:csharp, file: 'test_babel.cs', target_dir: "test/basic_complex_test/csharp_test")
end

