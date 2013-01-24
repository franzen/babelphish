
require 'divine'

struct 'DynamicInt' do
  list :list1, :dint63
end

# Draw ERD for prev. struct
Divine::GraphGenerator.new.draw("test/dynamic_int_test/")

if ARGV[0] == "ruby"
  Divine::CodeGenerator.new.generate(:ruby, file: 'test_dynamic_int.rb', module: 'BabelTest', parent_class: "Object", target_dir: "test/dynamic_int_test/ruby_test")
elsif ARGV[0] == "js"
  Divine::CodeGenerator.new.generate(:javascript, file: 'test_dynamic_int.js', target_dir: "test/dynamic_int_test/js_test")
elsif ARGV[0] == "java"
  Divine::CodeGenerator.new.generate(:java, file: 'test_dynamic_int.java', target_dir: "test/dynamic_int_test/java_test")
elsif ARGV[0] == "csharp"
  Divine::CodeGenerator.new.generate(:csharp, file: 'test_dynamic_int.cs', target_dir: "test/dynamic_int_test/csharp_test")

end
