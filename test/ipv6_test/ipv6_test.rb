
require 'divine'

struct 'IPV6' do
  list :list1, :ip_number
end

Divine::CodeGenerator.new.generate(:ruby, file: 'test_ipv6.rb', module: 'BabelTest', parent_class: "Object", target_dir: "/ruby_test")
Divine::CodeGenerator.new.generate(:javascript, file: 'test_ipv6.js', target_dir: "/js_test")
Divine::CodeGenerator.new.generate(:java, file: 'test_ipv6.java', package: "testip", target_dir: "/java_test")

