
require 'divine'

struct 'Node' do
  int32 :i32
  bool  :b
  list  :next_node, :Node  # List of nodes with size equals to 2, just to refer to the next left and right nodes in the tree
end

struct 'BinaryTree' do
  list :root_node, :Node   # List of root node of size equals to 1.
end

# Draw ERD for prev. structs
Divine::GraphGenerator.new.draw("test/binaryTree_test/", "graph", "png")

if ARGV[0] == "ruby"
  Divine::CodeGenerator.new.generate(:ruby, file: 'test_binaryTree.rb', module: 'BabelTest', parent_class: "Object", target_dir: 'test/binaryTree_test/ruby_test')
elsif ARGV[0] == "js"
  Divine::CodeGenerator.new.generate(:javascript, file: 'test_binaryTree.js', target_dir: 'test/binaryTree_test/js_test')
elsif ARGV[0] == "java"
  Divine::CodeGenerator.new.generate(:java, file: 'test_binaryTree.java', target_dir: 'test/binaryTree_test/java_test')
elsif ARGV[0] == "csharp"
  Divine::CodeGenerator.new.generate(:csharp, file: 'test_binaryTree.cs', target_dir: "test/binaryTree_test/csharp_test")
end
