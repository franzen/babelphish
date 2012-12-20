
require 'divine'

struct 'IPList' do
  list :list1, :ip_number
  list :list2, :ip_number
end

struct 'Complex' do
  list (:list1) {
    map(:string) { 
      list 'IPList'
    }
  }
end

if ARGV[0] == "ruby"
  Divine::CodeGenerator.new.generate(:ruby, file: 'test_complex.rb', module: 'BabelTest', parent_class: "Object", target_dir: 'test/complex_test/ruby_test')
elsif ARGV[0] == "js"
  Divine::CodeGenerator.new.generate(:javascript, file: 'test_complex.js', target_dir: 'test/complex_test/js_test')
elsif ARGV[0] == "java"
  Divine::CodeGenerator.new.generate(:java, file: 'test_complex.java', target_dir: 'test/complex_test/java_test')
end
