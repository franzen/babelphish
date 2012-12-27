
require 'divine'

struct 'SignedInt' do
  list :list1, :sint32
  #list :list2, :sint64
end

if ARGV[0] == "ruby"
  Divine::CodeGenerator.new.generate(:ruby, file: 'test_signed_int.rb', module: 'BabelTest', parent_class: "Object", target_dir: "test/signed_int_test/ruby_test")
elsif ARGV[0] == "js"
  Divine::CodeGenerator.new.generate(:javascript, file: 'test_signed_int.js', target_dir: "test/signed_int_test/js_test")
elsif ARGV[0] == "java"
  Divine::CodeGenerator.new.generate(:java, file: 'test_signed_int.java', target_dir: "test/signed_int_test/java_test")
end