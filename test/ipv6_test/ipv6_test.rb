
require 'divine'

struct 'IPV6' do
  list :list1, :ip_number
end

# Draw ERD for prev. structs
Divine::GraphGenerator.new.draw("test/ipv6_test/")

if ARGV[0] == "ruby"
  Divine::CodeGenerator.new.generate(:ruby, file: 'test_ipv6.rb', module: 'BabelTest', parent_class: "Object", target_dir: "test/ipv6_test/ruby_test")
elsif ARGV[0] == "js"
  Divine::CodeGenerator.new.generate(:javascript, file: 'test_ipv6.js', target_dir: "test/ipv6_test/js_test")
elsif ARGV[0] == "java"
  Divine::CodeGenerator.new.generate(:java, file: 'test_ipv6.java', target_dir: "test/ipv6_test/java_test")
elsif ARGV[0] == "csharp"
  Divine::CodeGenerator.new.generate(:csharp, file: 'test_ipv6.cs', target_dir: "test/ipv6_test/csharp_test")
end
