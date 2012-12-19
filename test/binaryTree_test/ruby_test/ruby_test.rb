require_relative 'test_binaryTree.rb'
require 'minitest/autorun'

class TestBabelTestBasic < MiniTest::Unit::TestCase

  def test_BinaryTree
    puts "Test Binary Tree"
    binaryTree_ser = buildTree
    
    ser = binaryTree_ser.serialize
    serialize(ser)
    res = deserialize()

    binaryTree_deser = BabelTest::BinaryTree.new
    binaryTree_deser.deserialize res
    compareBinaryTree(binaryTree_ser, binaryTree_deser)
    
  end

  def buildTree()
    root = BabelTest::Node.new
    root.i32 = 0
    
    n1_L = BabelTest::Node.new
    n1_L.i32 = 1

    n1_R = BabelTest::Node.new
    n1_R.i32 = 2

    n2_L_L = BabelTest::Node.new
    n2_L_L.i32 = 3

    n2_L_R = BabelTest::Node.new
    n2_L_R.i32 = 4

    n2_R_L = BabelTest::Node.new
    n2_R_L.i32 = 5

    n2_R_R = BabelTest::Node.new
    n2_R_R.i32 = 6

    root.next_node = [n1_L, n1_R]
    n1_L.next_node = [n2_L_L, n2_L_R]
    n1_R.next_node = [n2_R_L, n2_R_R]
    
    bt = BabelTest::BinaryTree.new
    bt.root_node = [root]
    bt
  end

  def compareBinaryTree(bt1, bt2)
    assert bt1.root_node.length == bt2.root_node.length
    assert bt1.root_node[0].i32 == bt2.root_node[0].i32
    assert bt1.root_node[0].next_node.length == bt2.root_node[0].next_node.length
    assert bt1.root_node[0].next_node[0].next_node[0].i32 == bt2.root_node[0].next_node[0].next_node[0].i32
  end

  def serialize(data)
    File.open("test/binaryTree_test/ruby_test/bin.babel.rb", "w+b") do |f|
      f.write(data)
    end
  end

  def deserialize()
    mem_buf = File.new('test/binaryTree_test/ruby_test/bin.babel.rb').binmode
  end

end
