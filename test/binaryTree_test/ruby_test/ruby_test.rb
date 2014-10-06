require_relative 'test_binaryTree.rb'
require 'minitest/autorun'

#
# Responsible for testing Binary Tree structure
#
class TestBinaryTree < MiniTest::Unit::TestCase

  #
  # Compare objects after serialize and deserialize operations
  #
  def test_BinaryTree
    puts "Test Binary Tree"
    binaryTree_ser = buildTree
    
    ser = binaryTree_ser.serialize
    serialize(ser)
    res = deserialize()

    binaryTree_deser = BabelTest::BinaryTree.new
    binaryTree_deser.deserialize res
    compare(binaryTree_ser, binaryTree_deser)
    
  end

  #
  # Initialize the original object
  #
  def buildTree()
    root = BabelTest::Node.new
    root.i32 = 0
    root.b = false
    
    n1_L = BabelTest::Node.new
    n1_L.i32 = 1
    n1_L.b = true
    
    n1_R = BabelTest::Node.new
    n1_R.i32 = 2
    n1_R.b = false

    n2_L_L = BabelTest::Node.new
    n2_L_L.i32 = 3
    n2_L_L.b = true
    
    n2_L_R = BabelTest::Node.new
    n2_L_R.i32 = 4
    n2_L_R.b = false

    n2_R_L = BabelTest::Node.new
    n2_R_L.i32 = 5
    n2_R_L.b = true

    n2_R_R = BabelTest::Node.new
    n2_R_R.i32 = 6
    n2_R_R.b = false

    root.next_node = [n1_L, n1_R]
    n1_L.next_node = [n2_L_L, n2_L_R]
    n1_R.next_node = [n2_R_L, n2_R_R]
    
    bt = BabelTest::BinaryTree.new
    bt.root_node = [root]
    bt
  end

  #
  # Make sure that the comming two objects are the same
  # * *Args* :
  #  -obj_ser-   --> original object
  #  -obj_deser- --> obtained object after serialize and deserialize operations
  #
  def compare(bt1, bt2)
    assert_equal bt1.root_node.length, bt2.root_node.length
    assert_equal bt1.root_node[0].b, bt2.root_node[0].b
    assert_equal bt1.root_node[0].i32, bt2.root_node[0].i32
    assert_equal bt1.root_node[0].next_node.length, bt2.root_node[0].next_node.length
    assert_equal bt1.root_node[0].next_node[0].next_node[0].i32, bt2.root_node[0].next_node[0].next_node[0].i32
  end

  #
  # Write binary data to file
  # * *Args* :
  #  -data-   --> bytes to be written
  #
  def serialize(data)
    File.open("test/binaryTree_test/ruby_test/bin.babel.rb", "w+b") do |f|
      f.write(data)
    end
  end

  #
  # Read file in binary mode and return its bytes content
  #
  def deserialize()
    mem_buf = File.new('test/binaryTree_test/ruby_test/bin.babel.rb').binmode
  end

end
