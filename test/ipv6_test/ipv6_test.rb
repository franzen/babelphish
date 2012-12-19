
require 'divine'

struct 'IPV6' do
  list :list1, :ip_number
end

Divine::CodeGenerator.new.generate(:ruby, file: 'test_ipv6.rb', module: 'BabelTest', parent_class: "Object", target_dir: "test/ipv6_test/ruby_test")
Divine::CodeGenerator.new.generate(:javascript, file: 'test_ipv6.js', target_dir: "test/ipv6_test/js_test")
Divine::CodeGenerator.new.generate(:java, file: 'test_ipv6.java', target_dir: "test/ipv6_test/java_test")

