
require 'divine'

struct 'SignedFloat' do
  list :list1, :float32
end

if ARGV[0] == "ruby"
  Divine::CodeGenerator.new.generate(:ruby, file: 'test_signed_float.rb', module: 'BabelTest', parent_class: "Object", target_dir: "test/signed_float_test/ruby_test")
elsif ARGV[0] == "js"
  Divine::CodeGenerator.new.generate(:javascript, file: 'test_signed_float.js', target_dir: "test/signed_float_test/js_test")
elsif ARGV[0] == "java"
  Divine::CodeGenerator.new.generate(:java, file: 'test_signed_float.java', target_dir: "test/signed_float_test/java_test")
end
