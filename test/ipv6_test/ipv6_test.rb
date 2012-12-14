
require 'divine'

struct 'IPV6' do
  ip_number :ip
  ipv6_number :ipv6
end

Divine::CodeGenerator.new.generate(:ruby, file: 'test_ipv6.rb', module: 'BabelTest', parent_class: "Object")
#Divine::CodeGenerator.new.generate(:javascript, file: 'test_ipv6.js')
Divine::CodeGenerator.new.generate(:java, file: 'test_ipv6.java')

