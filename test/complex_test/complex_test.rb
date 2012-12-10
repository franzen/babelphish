
require 'divine'

struct 'IPList' do
  list :list1, :ip_number
end

struct 'Complex' do
  list (:list1) {
    map(:string) { 
      list 'IPList'
    }
  }
end


Divine::CodeGenerator.new.generate(:ruby, file: 'test_complex.rb', module: 'BabelTest', parent_class: "Object")
Divine::CodeGenerator.new.generate(:javascript, file: 'test_complex.js')
Divine::CodeGenerator.new.generate(:java, file: 'test_complex.java')

